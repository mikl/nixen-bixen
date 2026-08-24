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
    { pkgs, lib, ... }:
    let
      noctaliaBin = lib.getExe pkgs.noctalia;
      xwaylandSatellite = lib.getExe pkgs.xwayland-satellite;

      # v5 speaks over a Unix socket in XDG_RUNTIME_DIR: `noctalia msg <cmd>`.
      # (v4's `ipc call <target> <fn>` form is gone.)
      msg = args: ''spawn "${noctaliaBin}" "msg" ${lib.concatMapStringsSep " " (a: ''"${a}"'') args}'';
    in
    {
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
        # Eidolon has no internal panel, so /sys/class/backlight is empty and
        # brightness control has to go out over DDC/CI.
        enable_ddcutil = true
      '';

      xdg.configFile."niri/config.kdl".text = ''
        // Generated from modules/features/niri/home.nix — edits here are lost
        // on the next home-manager switch.

        input {
            // Mirrors services.xserver.xkb from modules/features/l10n/keyboard.nix.
            // niri does not read that; it would otherwise ask locale1, which
            // only knows the layout, not the variant or options.
            keyboard {
                xkb {
                    model "pc104alt"
                    layout "us"
                    variant "mac-iso"
                    options "lv3:ralt_switch,terminate:ctrl_alt_bksp,caps:escape"
                }
                numlock
            }

            touchpad {
                tap
                natural-scroll
            }

            focus-follows-mouse max-scroll-amount="0%"
        }

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

        prefer-no-csd

        hotkey-overlay {
            skip-at-startup
        }

        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

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
      '';
    };
}
