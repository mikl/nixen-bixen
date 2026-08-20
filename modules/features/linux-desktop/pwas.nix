/**
  Desktop launchers for web apps via Home Manager's programs.firefoxpwa
  (PWAsForFirefox). Work apps share a "Reload" profile so sessions stay
  separate from personal browsing; personal apps use the default profile.
*/
{ self, ... }:
{
  flake.homeModules.linuxDesktopPwas =
    { pkgs, lib, ... }:
    let
      # Stable ULIDs so profile/site IDs don't churn across rebuilds.
      # Hex is a subset of Crockford base32, but the first character of a ULID
      # only encodes 2 bits (values 0-7). A hash that starts with 8-F gets
      # silently remapped by the ulid crate (8DCF… → 0DCF… on disk).
      mkUlid = seed: "0" + lib.toUpper (builtins.substring 0 25 (builtins.hashString "sha256" seed));

      # Nil ULID is PWAsForFirefox's built-in default profile.
      defaultProfileUlid = "00000000000000000000000000";
      reloadProfileUlid = mkUlid "firefoxpwa:profile:reload";

      siteUlid = id: mkUlid "firefoxpwa:site:${id}";
      appId = id: "FFPWA-${siteUlid id}";

      # Sites without a usable web app manifest (missing, login-gated, or
      # rejected by PWAsForFirefox's parser — see X / Twitter) get an inline
      # data-URL manifest instead. Launching uses the stored config, not a fetch.
      inlineManifest =
        { name, url }:
        "data:application/manifest+json,${
          lib.escapeURL (
            builtins.toJSON {
              inherit name;
              short_name = name;
              start_url = url;
              display = "standalone";
            }
          )
        }";

      apps = {
        harvest = {
          name = "Harvest";
          genericName = "Time Tracking";
          url = "https://reload.harvestapp.com/";
          manifestUrl = "https://reload.harvestapp.com/site.webmanifest";
          iconUrl = "https://id.getharvest.com/favicon.svg";
          iconHash = "sha256-P25jqAr7JRHyl52Omxse1yoXGkThMRk8lCGCbMoUpGA=";
          profile = "reload";
        };
        gmail = {
          name = "Gmail";
          genericName = "Email";
          url = "https://mail.google.com/mail/";
          manifestUrl = "https://mail.google.com/mail/manifest.json";
          iconUrl = "https://www.gstatic.com/images/branding/productlogos/gmail_2026/v2/web/192px.svg";
          iconHash = "sha256-CiQhMUJLeWomJHqO3UHWb6KU2m0XeJdSahm36Brt/bg=";
          profile = "reload";
        };
        google-calendar = {
          name = "Google Calendar";
          genericName = "Calendar";
          url = "https://calendar.google.com/calendar/";
          manifestUrl = "https://calendar.google.com/calendar/manifest.json";
          iconUrl = "https://www.gstatic.com/images/branding/productlogos/calendar_2026/v2/web/192px.svg";
          iconHash = "sha256-f1XNh3siYZSBaNs9LpRowM8/B3ZniUiehToPmTHf+Oo=";
          profile = "reload";
        };
        google-meet = rec {
          name = "Google Meet";
          genericName = "Video Conferencing";
          url = "https://meet.google.com/";
          manifestUrl = inlineManifest { inherit name url; };
          iconUrl = "https://www.gstatic.com/images/branding/productlogos/meet_2026/v2/web/192px.svg";
          iconHash = "sha256-ri6GqgCf1+GVIIK/99T6nsqPRf9G0CmIANU8XWvcs7Q=";
          profile = "reload";
        };
        # Meta is winding down the standalone messenger.com site and steering
        # users to Messenger inside facebook.com instead, so this points
        # straight there rather than relying on a redirect that may go away.
        messenger = rec {
          name = "Messenger";
          genericName = "Messaging";
          url = "https://www.facebook.com/messages/";
          manifestUrl = inlineManifest { inherit name url; };
          iconUrl = "https://upload.wikimedia.org/wikipedia/commons/6/63/Facebook_Messenger_logo_2025.svg";
          iconHash = "sha256-WpfdCU+yolH/kesbbM1//x3V9D/hTcZR/Vl4nPGFT5A=";
          profile = "default";
        };
        # X's official manifest is invalid (screenshots/shortcuts without image
        # URLs); PWAsForFirefox rejects it. Use an inline manifest instead.
        x = rec {
          name = "X";
          genericName = "Social Networking";
          url = "https://x.com/home";
          manifestUrl = inlineManifest { inherit name url; };
          iconUrl = "https://upload.wikimedia.org/wikipedia/commons/c/ce/X_logo_2023.svg";
          iconHash = "sha256-nlK29rcb4uO9o0xo1J4Krww1Q22tGqNnu6dL+3wp6s4=";
          profile = "default";
        };
        claude = {
          name = "Claude";
          genericName = "AI Assistant";
          url = "https://claude.ai/";
          manifestUrl = "https://claude.ai/manifest.json";
          iconUrl = "https://claude.ai/favicon.svg";
          iconHash = "sha256-sVCIi8clevg+O4XTwr5ClPiJhgJvgWj2wS/B/eZpc1A=";
          profile = "reload";
        };
      };

      mkIcon =
        app:
        pkgs.fetchurl {
          url = app.iconUrl;
          hash = app.iconHash;
        };

      mkIconPng =
        svg:
        pkgs.runCommand "pwa-icon.png" { nativeBuildInputs = [ pkgs.librsvg ]; } ''
          rsvg-convert -w 128 -h 128 ${svg} -o $out
        '';

      toFirefoxSite = app: {
        inherit (app) name url manifestUrl;
        desktopEntry = {
          categories = [ "Network" ];
          icon = mkIcon app;
        };
        settings.config.icon_url = app.iconUrl;
      };

      sitesFor =
        profile:
        lib.mapAttrs' (id: app: lib.nameValuePair (siteUlid id) (toFirefoxSite app)) (
          lib.filterAttrs (_: app: app.profile == profile) apps
        );

      # Plasma's task manager matches StartupWMClass against resourceName
      # *before* the Wayland app_id. Firefox's resourceName is the binary
      # name ("firefox"), so every PWA would be grouped under Firefox unless
      # we exec the runtime as FFPWA-<ulid>.
      pwaSysdata =
        let
          realRuntime = "${pkgs.firefoxpwa}/share/firefoxpwa/runtime/firefox";
          runtimeWrapper = pkgs.writeShellScript "firefoxpwa-runtime" ''
            set -euo pipefail
            exec -a "''${MOZ_APP_LAUNCHER:-firefox}" ${lib.escapeShellArg realRuntime} "$@"
          '';
        in
        pkgs.runCommand "firefoxpwa-sysdata" { } ''
          mkdir -p $out
          cp -a ${pkgs.firefoxpwa}/share/firefoxpwa/. $out/
          chmod -R u+w $out/runtime
          rm -f $out/runtime/firefox
          cp ${runtimeWrapper} $out/runtime/firefox
        '';

      mkLauncher =
        id: app:
        let
          ulid = siteUlid id;
        in
        pkgs.writeShellScript "launch-${appId id}" ''
          set -euo pipefail
          # Pull LD_LIBRARY_PATH / MOZ_SYSTEM_DIR / etc. from the firefoxpwa
          # wrapper without taking its hardcoded MOZ_APP_LAUNCHER.
          eval "$(${pkgs.gnused}/bin/sed '/^exec /,$d; /^#!/d' ${lib.getExe pkgs.firefoxpwa})"
          export MOZ_APP_LAUNCHER=${lib.escapeShellArg (appId id)}
          export FFPWA_SYSDATA=${lib.escapeShellArg pwaSysdata}
          extra=()
          if [[ $# -gt 0 && -n "''${1:-}" ]]; then
            extra+=(--protocol "$1")
          fi
          # Both firefoxpwa wrappers *prefix* FFPWA_SYSDATA with the package's
          # own share dir (makeWrapper `--prefix FFPWA_SYSDATA :`), but the
          # binary reads the variable as a single path -- going through them
          # would turn our override into "<pkg-sysdata>:<our-sysdata>", which
          # is not a directory ("Runtime not installed"). Exec the unwrapped
          # binary so the override survives.
          exec ${lib.escapeShellArg "${pkgs.firefoxpwa}/bin/.firefoxpwa-wrapped"} site launch ${ulid} "''${extra[@]}"
        '';
    in
    {
      programs.firefoxpwa = {
        enable = true;
        settings.config = {
          runtime_enable_wayland = true;
          runtime_use_portals = true;
        };
        profiles = {
          ${defaultProfileUlid} = {
            name = "Default";
            sites = sitesFor "default";
          };
          ${reloadProfileUlid} = {
            name = "Reload";
            sites = sitesFor "reload";
          };
        };
      };

      xdg.dataFile = lib.mkMerge (
        lib.mapAttrsToList (
          id: app:
          let
            svg = mkIcon app;
            name = appId id;
          in
          {
            "icons/hicolor/scalable/apps/${name}.svg".source = svg;
            "icons/hicolor/128x128/apps/${name}.png".source = mkIconPng svg;
          }
        ) apps
      );

      # Override the Home Manager-generated launchers: theme icon, process
      # name / app_id, and StartupWMClass all equal FFPWA-<ulid> so KDE keeps
      # each PWA on its own task-manager entry.
      xdg.desktopEntries = lib.mkMerge (
        lib.mapAttrsToList (id: app: {
          ${appId id} = {
            genericName = app.genericName;
            icon = lib.mkForce (appId id);
            exec = lib.mkForce "${mkLauncher id app} %u";
            settings.StartupWMClass = appId id;
          };
        }) apps
      );
    };

  flake.nixosModules.linuxDesktopPwas =
    { pkgs, ... }:
    {
      # Each PWA is its own Firefox profile, so the password manager has to
      # come along for any of them to be usable.
      imports = [ self.nixosModules.linuxDesktopOnePassword ];

      # Lets the PWAsForFirefox extension talk to the native host.
      programs.firefox.nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
    };
}
