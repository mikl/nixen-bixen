/**
  Niri compositor config plus the Noctalia shell that runs on top of it.

  Noctalia v5 layers its configuration: every `*.toml` under
  ~/.config/noctalia is merged, and ~/.local/state/noctalia/settings.toml is
  read last as an override layer. The settings GUI only ever writes that state
  file, so a read-only config.toml here is the intended packaging model rather
  than something that fights the UI — anything set below is a default the GUI
  can still shadow.
*/
{ ... }:
{
  flake.homeModules.niriHomeManager =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      noctaliaBin = lib.getExe pkgs.noctalia;
      xwaylandSatellite = lib.getExe pkgs.xwayland-satellite;

      # v5 speaks over a Unix socket in XDG_RUNTIME_DIR: `noctalia msg <cmd>`.
      # (v4's `ipc call <target> <fn>` form is gone.)
      msg = args: ''spawn "${noctaliaBin}" "msg" ${lib.concatMapStringsSep " " (a: ''"${a}"'') args}'';

      # The virtual desktops carried over from the Plasma session, listed in the
      # order they had there. Named workspaces sort ahead of unnamed ones, so
      # Mod+1/2/3 reach these the way Meta+1/2/3 did under KDE.
      workspaceNames = [
        "udforskning"
        "kodning"
        "snak"
      ];

      # A KDE desktop spanned every screen, but a niri workspace belongs to
      # one output — and niri cannot express "whichever big screen is
      # attached": open-on-output takes one exact connector or make/model/
      # serial string, and a workspace whose output never shows up silently
      # stays on whatever connected first, which may well be the laptop panel.
      # With two different main monitors in play that is not good enough, so
      # the blocks stay bare and placeWorkspaces below sorts it out over IPC
      # against whatever is actually plugged in.
      workspaceBlocks = lib.concatMapStringsSep "\n" (name: ''workspace "${name}"'') workspaceNames;

      placeWorkspaces = pkgs.writeShellApplication {
        name = "niri-arrange-displays";
        runtimeInputs = [
          pkgs.niri
          pkgs.jq
        ];
        text = ''
          # In the order they should sit on the main screen.
          names=(${lib.escapeShellArgs workspaceNames})

          # A tiled display — the 5K Studio Display, say — arrives as two
          # connectors carrying byte-identical EDID, one per tile. niri refuses
          # to let two outputs share an identity and strips make, model and
          # serial from the second, leaving a blank screen that shows nothing.
          #
          # That ghost cannot be named in the config: with no make/model/serial
          # left, OutputName::matches bails out before it would compare the
          # "Unknown Unknown Unknown" form, so only its connector matches — and
          # which connector it lands on depends on the port. Over IPC, however,
          # the missing fields do read back as "Unknown", so it can be spotted
          # wherever it turns up and switched off by connector.
          prune_ghosts() {
              local outputs enabled connector

              outputs=$(niri msg -j outputs)
              enabled=$(printf '%s' "$outputs" \
                  | jq '[to_entries[] | select(.value.logical != null)] | length')

              while read -r connector; do
                  [[ -n "$connector" ]] || continue
                  # Never black the machine out: leave the last screen alone,
                  # however unidentifiable it is.
                  [[ $enabled -gt 1 ]] || break
                  niri msg output "$connector" off
                  enabled=$((enabled - 1))
              done < <(printf '%s' "$outputs" | jq -r '
                  to_entries[]
                  | select(.value.logical != null
                           and .value.make == "Unknown"
                           and .value.model == "Unknown")
                  | .key
              ')
          }

          place() {
              local main outputs workspaces on moved=0 idx=1

              outputs=$(niri msg -j outputs)
              # A disabled output reports a null logical rectangle, which is how
              # the Studio Display's dead second tile drops out of this.
              main=$(printf '%s' "$outputs" | jq -r '
                  to_entries
                  | map(select(.value.logical != null
                               and (.key | test("^(eDP-|LVDS|DSI-)") | not)))
                  | .[0].key // empty
              ')

              # Laptop on its own: nowhere else for them to go.
              [[ -n "$main" ]] || return 0

              workspaces=$(niri msg -j workspaces)
              for name in "''${names[@]}"; do
                  on=$(printf '%s' "$workspaces" \
                      | jq -r --arg n "$name" '.[] | select(.name == $n) | .output')
                  [[ -n "$on" && "$on" != "$main" ]] || continue
                  niri msg action move-workspace-to-monitor "$main" --reference "$name"
                  moved=1
              done

              # A move inserts the workspace just after the target's active one
              # rather than at the end, so the order has to be restated. Only
              # after an actual move, though, so that reordering workspaces by
              # hand is not undone on the next event.
              [[ $moved -eq 1 ]] || return 0
              for name in "''${names[@]}"; do
                  niri msg action move-workspace-to-index "$idx" --reference "$name"
                  idx=$((idx + 1))
              done
          }

          prune_ghosts
          place

          # Outputs coming and going surface as a workspace reshuffle. The moves
          # above emit these events too, but the pass they trigger finds nothing
          # left to do, so the cascade stops after one round.
          niri msg -j event-stream | while read -r event; do
              case $event in
                  *'"WorkspacesChanged"'*)
                      prune_ghosts
                      place
                      ;;
              esac
          done
        '';
      };
    in
    {
      options.local.niri.outputs = lib.mkOption {
        type = lib.types.lines;
        default = "";
        example = ''
          output "eDP-1" {
              scale 2
          }
        '';
        description = ''
          Host-specific niri `output` blocks, spliced into the generated
          config.kdl. Output rules only make sense per machine — connector
          names in particular mean nothing on another host — so they live in
          the host's home module rather than in this feature.
        '';
      };

      options.local.niri.extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Host-specific KDL appended to the generated config.kdl, for rules
          that name an output and so cannot be shared — pinning an app to a
          particular screen, say. Placement onto a workspace is shared and
          lives in this feature instead.
        '';
      };

      config = {
        home.packages = with pkgs; [
          noctalia
          niri # for `niri msg` outside the session

          # Noctalia's brightness backend for external monitors shells out to
          # ddcutil; see hardware.i2c in the NixOS half of this feature.
          ddcutil

          # v5 has no MPRIS IPC verb, so media keys go through playerctl.
          playerctl
        ];

        xdg.configFile."noctalia/config.toml".text = ''
          # Generated from modules/features/niri/home.nix — edits here are lost on
          # the next home-manager switch. Change things in Noctalia's settings
          # panel instead; those land in ~/.local/state/noctalia/settings.toml,
          # which is read after this file and wins.

          [shell]
          # v5 ships its own polkit agent, so no separate polkit-kde-agent-1 runs
          # in the session. Two agents would fight over the authority.
          polkit_agent = true

          # Typing in niri's overview opens the Noctalia launcher.
          niri_overview_type_to_launch_enabled = true

          [brightness]
          # External monitors have no /sys/class/backlight entry, so their
          # brightness has to be driven over DDC/CI instead. (Not that it helps
          # with an Apple Studio Display, which answers a proprietary HID
          # protocol rather than DDC — that is what asdbctl is for.)
          enable_ddcutil = true
        '';

        xdg.configFile."niri/config.kdl".text = ''
          // Generated from modules/features/niri/home.nix — edits here are lost
          // on the next home-manager switch.

          input {
              // No xkb block on purpose. niri only consults it when the config
              // sets one; left empty it takes model, layout, variant and
              // options from locale1, which systemd populates from
              // /etc/X11/xorg.conf.d/00-keyboard.conf — generated in turn from
              // services.xserver.xkb in modules/features/l10n/keyboard.nix.
              // That keeps one source of truth for the keymap, and niri
              // follows later changes to it live.
              keyboard {
                  numlock
              }

              touchpad {
                  tap
                  natural-scroll
              }

              focus-follows-mouse max-scroll-amount="0%"
          }

          ${config.local.niri.outputs}

          ${workspaceBlocks}

          layout {
              gaps 12
              center-focused-column "never"

              preset-column-widths {
                  proportion 0.33333
                  proportion 0.5
                  proportion 0.66667
              }

              default-column-width { proportion 0.5; }

              focus-ring {
                  width 2
                  // Breeze accent, so the focus ring matches KDE apps.
                  active-color "#3daee9"
                  inactive-color "#4d4d4d"
              }

              border {
                  off
              }

              // Carried over from the old config; niri draws no shadow by default.
              shadow {
                  softness 30
                  spread 5
                  offset x=0 y=5
                  color "#0007"
              }
          }

          cursor {
              xcursor-theme "breeze_cursors"
              xcursor-size 24
          }

          xwayland-satellite {
              path "${xwaylandSatellite}"
          }

          // Foreground rather than `--daemon`: niri owns the child, and its
          // stderr then lands in the niri log.
          spawn-at-startup "${noctaliaBin}"

          // Puts the named workspaces on the main screen and keeps them there
          // across docking changes; stays running to watch the event stream.
          spawn-at-startup "${lib.getExe placeWorkspaces}"

          prefer-no-csd

          hotkey-overlay {
              skip-at-startup
          }

          screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

          // Application placement, translated from the Plasma session's
          // ~/.config/kwinrulesrc and added to since. KDE matched on X11
          // WM_CLASS, which is not always the Wayland app ID — 1Password's
          // desktop entry advertises `1Password` where niri sees `1password`
          // — so these match case-insensitively rather than guessing per app.
          // Rules for applications a given host does not install are inert.
          //
          // Not translated: the rules pinning Slack, Telegram and
          // teams-for-linux to a KDE activity, which has no niri equivalent
          // (and that activity no longer exists in kactivitymanagerdrc); the
          // librewolf rule, its package being commented out in develop.nix as
          // unmaintained; and the "all desktops" rules for 1Password, Obsidian
          // and systemsettings, which describe niri's default behaviour.
          window-rule {
              match app-id=r#"(?i)^zen"#
              match app-id=r#"(?i)^vivaldi"#
              match app-id=r#"(?i)^chromium(-browser)?$"#
              open-on-workspace "udforskning"
          }

          window-rule {
              match app-id=r#"(?i)^firefox$"#
              match app-id=r#"(?i)^dev\.zed\.zed$"#
              match app-id=r#"(?i)^jetbrains-phpstorm$"#
              open-on-workspace "kodning"
          }

          // KWin had this one maximized both ways; the niri equivalent is a
          // column taking the full width of the output.
          window-rule {
              match app-id=r#"(?i)^com\.mitchellh\.ghostty$"#
              open-on-workspace "kodning"
              open-maximized true
          }

          window-rule {
              match app-id=r#"(?i)^zulip$"#
              match app-id=r#"(?i)^signal$"#
              match app-id=r#"(?i)^(com\.rtosta\.)?zapzap$"#
              match app-id=r#"(?i)^proton-mail$"#
              open-on-workspace "snak"
          }

          window-rule {
              match app-id=r#"(?i)^thunderbird$"#
              open-on-workspace "snak"
              open-maximized true
          }

          // Gmail, Google Calendar and Messenger. The rules in kwinrulesrc
          // still match the Brave- and Vivaldi-hosted PWAs from before the
          // move to PWAsForFirefox; these are the site IDs firefoxpwa derives
          // from the seeds in pwas.nix, confirmed against `niri msg windows`.
          window-rule {
              match app-id=r#"^FFPWA-04334C99A477587D3281AF14B9$"#
              match app-id=r#"^FFPWA-03FC2FDD27CF6643318BDF96EE$"#
              match app-id=r#"^FFPWA-00A03CA47A3AD2E5D322D9B008$"#
              open-on-workspace "snak"
          }

          // Anything holding credentials is blocked from capture entirely —
          // "screen-capture" covers screenshots as well as screencasts, so
          // these windows come out blank even in a screenshot you take
          // yourself. From the old config, which matched `^1Password$`; the
          // Wayland app ID is lowercase, hence the (?i) throughout.
          window-rule {
              match app-id=r#"(?i)^1password$"#
              match app-id=r#"(?i)^(org\.kde\.)?kwalletmanager"#
              match app-id=r#"(?i)^org\.keepassxc\.KeePassXC$"#
              match app-id=r#"(?i)^org\.gnome\.World\.Secrets$"#
              block-out-from "screen-capture"
          }

          // Mail and chat get the weaker "screencast" instead: blanked out
          // when sharing a screen or recording, but still yours to screenshot.
          // Blocking these from screenshots too would mostly get in the way of
          // sending someone a picture of your own inbox or a conversation.
          window-rule {
              match app-id=r#"(?i)^thunderbird$"#
              match app-id=r#"(?i)^proton-mail$"#
              match app-id=r#"(?i)^ch\.proton\.bridge-gui$"#
              match app-id=r#"(?i)^signal$"#
              match app-id=r#"(?i)^zulip$"#
              match app-id=r#"(?i)^(com\.rtosta\.)?zapzap$"#
              // Gmail and Messenger, by PWAsForFirefox site ID.
              match app-id=r#"^FFPWA-04334C99A477587D3281AF14B9$"#
              match app-id=r#"^FFPWA-00A03CA47A3AD2E5D322D9B008$"#
              block-out-from "screencast"
          }

          // Firefox/Zen picture-in-picture should float.
          window-rule {
              match app-id=r#"firefox$"# title="^Picture-in-Picture$"
              match app-id=r#"^zen"# title="^Picture-in-Picture$"
              open-floating true
          }

          binds {
              Mod+Shift+Slash { show-hotkey-overlay; }

              // Programs. Mod+E for the file manager matches KDE's Meta+E.
              Mod+Return hotkey-overlay-title="Open a Terminal" { spawn "ghostty"; }
              Mod+E hotkey-overlay-title="Open Dolphin" { spawn "dolphin"; }

              // Noctalia panels.
              Mod+D hotkey-overlay-title="Application Launcher" { ${
                msg [
                  "panel-toggle"
                  "launcher"
                ]
              }; }
              Mod+Space hotkey-overlay-title="Application Launcher" { ${
                msg [
                  "panel-toggle"
                  "launcher"
                ]
              }; }
              Mod+V hotkey-overlay-title="Clipboard History" { ${
                msg [
                  "panel-toggle"
                  "clipboard"
                ]
              }; }
              Mod+A hotkey-overlay-title="Control Centre" { ${
                msg [
                  "panel-toggle"
                  "control-center"
                  "home"
                ]
              }; }
              Mod+N hotkey-overlay-title="Notifications" { ${
                msg [
                  "panel-toggle"
                  "control-center"
                  "notifications"
                ]
              }; }
              Mod+Shift+W hotkey-overlay-title="Wallpaper Picker" { ${
                msg [
                  "panel-toggle"
                  "wallpaper"
                ]
              }; }
              Mod+Tab hotkey-overlay-title="Window Switcher" { ${msg [ "window-switcher" ]}; }
              Mod+Comma hotkey-overlay-title="Noctalia Settings" { ${msg [ "settings-toggle" ]}; }
              Mod+B hotkey-overlay-title="Toggle the Bar" { ${msg [ "bar-toggle" ]}; }
              Mod+Shift+A hotkey-overlay-title="Toggle Idle Inhibitor" { ${msg [ "caffeine-toggle" ]}; }

              // Session. Ctrl+Alt+Delete opening a session menu matches KDE.
              Super+Alt+L hotkey-overlay-title="Lock the Screen" { ${
                msg [
                  "session"
                  "lock"
                ]
              }; }
              Ctrl+Alt+Delete hotkey-overlay-title="Session Menu" { ${
                msg [
                  "panel-toggle"
                  "session"
                ]
              }; }
              Mod+Shift+E { quit; }

              // Volume and brightness through Noctalia so its OSD shows up.
              XF86AudioRaiseVolume allow-when-locked=true { ${msg [ "volume-up" ]}; }
              XF86AudioLowerVolume allow-when-locked=true { ${msg [ "volume-down" ]}; }
              XF86AudioMute        allow-when-locked=true { ${msg [ "volume-mute" ]}; }
              XF86AudioMicMute     allow-when-locked=true { ${msg [ "mic-mute" ]}; }
              XF86MonBrightnessUp   allow-when-locked=true { ${msg [ "brightness-up" ]}; }
              XF86MonBrightnessDown allow-when-locked=true { ${msg [ "brightness-down" ]}; }

              XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
              XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }
              XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }

              // Window and column management (niri defaults).
              Mod+O repeat=false { toggle-overview; }
              Mod+Q repeat=false { close-window; }

              Mod+Left  { focus-column-left; }
              Mod+Down  { focus-window-down; }
              Mod+Up    { focus-window-up; }
              Mod+Right { focus-column-right; }
              Mod+H     { focus-column-left; }
              Mod+J     { focus-window-down; }
              Mod+K     { focus-window-up; }
              Mod+L     { focus-column-right; }

              Mod+Ctrl+Left  { move-column-left; }
              Mod+Ctrl+Down  { move-window-down; }
              Mod+Ctrl+Up    { move-window-up; }
              Mod+Ctrl+Right { move-column-right; }
              Mod+Ctrl+H     { move-column-left; }
              Mod+Ctrl+J     { move-window-down; }
              Mod+Ctrl+K     { move-window-up; }
              Mod+Ctrl+L     { move-column-right; }

              Mod+Home { focus-column-first; }
              Mod+End  { focus-column-last; }

              Mod+Shift+Left  { focus-monitor-left; }
              Mod+Shift+Down  { focus-monitor-down; }
              Mod+Shift+Up    { focus-monitor-up; }
              Mod+Shift+Right { focus-monitor-right; }

              Mod+Page_Down      { focus-workspace-down; }
              Mod+Page_Up        { focus-workspace-up; }
              Mod+U              { focus-workspace-down; }
              Mod+I              { focus-workspace-up; }
              Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
              Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }

              Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
              Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
              Mod+WheelScrollRight     { focus-column-right; }
              Mod+WheelScrollLeft      { focus-column-left; }

              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+9 { focus-workspace 9; }
              Mod+Ctrl+1 { move-column-to-workspace 1; }
              Mod+Ctrl+2 { move-column-to-workspace 2; }
              Mod+Ctrl+3 { move-column-to-workspace 3; }
              Mod+Ctrl+4 { move-column-to-workspace 4; }
              Mod+Ctrl+5 { move-column-to-workspace 5; }
              Mod+Ctrl+6 { move-column-to-workspace 6; }
              Mod+Ctrl+7 { move-column-to-workspace 7; }
              Mod+Ctrl+8 { move-column-to-workspace 8; }
              Mod+Ctrl+9 { move-column-to-workspace 9; }

              Mod+BracketLeft  { consume-or-expel-window-left; }
              Mod+BracketRight { consume-or-expel-window-right; }
              Mod+Period { expel-window-from-column; }

              Mod+R { switch-preset-column-width; }
              Mod+Shift+R { switch-preset-column-width-back; }
              Mod+Ctrl+R { reset-window-height; }

              Mod+F { maximize-column; }
              Mod+Shift+F { fullscreen-window; }
              Mod+M { maximize-window-to-edges; }
              Mod+Ctrl+F { expand-column-to-available-width; }
              Mod+C { center-column; }

              Mod+Minus { set-column-width "-10%"; }
              Mod+Equal { set-column-width "+10%"; }
              Mod+Shift+Minus { set-window-height "-10%"; }
              Mod+Shift+Equal { set-window-height "+10%"; }

              Mod+Shift+V { toggle-window-floating; }
              Mod+W { toggle-column-tabbed-display; }

              // Screenshots: Noctalia's own capture (wlr-screencopy, which niri
              // implements) is the closest thing to Spectacle here — Spectacle
              // itself drives KWin's screenshot API and cannot work. niri's
              // built-ins cover the window case and stand in if the shell is down.
              Print { ${msg [ "screenshot-region" ]}; }
              Ctrl+Print { ${msg [ "screenshot-fullscreen" ]}; }
              Alt+Print { screenshot-window; }
              Mod+Print { screenshot; }

              Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
              Mod+Shift+P { power-off-monitors; }
          }

          ${config.local.niri.extraConfig}
        '';
      };
    };
}
