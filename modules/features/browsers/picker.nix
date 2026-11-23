/**
  Browsers (https://browsers.software), the browser picker that routes
  links to a browser by URL pattern. Its settings UI is fiddly, so the
  whole config lives here instead.

  Browsers names each browser by the executable in its .desktop file's Exec
  line. For packages whose desktop file uses a bare name (firefox, zen-beta,
  chromium) that is stable; for those that use an absolute store path
  (Vivaldi, Brave Origin) it changes on every update, which silently broke
  hand-made rules. Deriving those paths from the installed packages keeps
  the rules pointing at the browser that is actually there.
*/
{ ... }:
{
  flake.homeModules.browsersPicker =
    {
      config,
      options,
      lib,
      pkgs,
      ...
    }:
    let
      # The very package another module installed, so the store path matches
      # its desktop file. Evaluation fails if it isn't installed.
      installed =
        name:
        lib.findFirst (p: lib.getName p == name)
          (throw "browsersPicker: ${name} is not in home.packages")
          config.home.packages;

      # Profile IDs: "<executable>#<profile>". The profile is the name the
      # browser is started with (Firefox profile name, Chromium profile
      # directory), empty for browsers Browsers knows no profiles for.
      browsers = {
        zen = "zen-beta#";
        firefoxWork = "firefox#Master";
        chromium = "chromium#Default";
        vivaldi = "${lib.getExe (installed "vivaldi")}#Default";
        brave = "${lib.getExe (installed "brave-origin")}#";
      };

      # URL patterns per browser. `*` matches one hostname label, `**` any
      # number of them, including none (so **.github.com covers github.com).
      routes = {
        firefoxWork = [
          "**.atlassian.net"
          "**.github.com"
          "**.gitlab.com"
          "**.harvestapp.com"
          "**.mynixos.com"
          "**.nixos.org"
          "**.reload.dk"
          "**.sentry.io"
          # Local development.
          "**.ddev.site"
          "**.local"
          "**.localhost"
          "**.test"
        ];
        vivaldi = [
          "drive.google.com"
          "mail.google.com"
          "meet.google.com"
        ];
        brave = [
          "**.youtu.be"
          "**.youtube.*"
        ];
      };

      opener = browser: {
        profile = browsers.${browser};
        incognito = false;
      };

      settings = {
        default_profile = opener "zen";

        rules = lib.concatLists (
          lib.mapAttrsToList (
            browser: patterns:
            map (url_pattern: {
              source_app = null;
              inherit url_pattern;
              opener = opener browser;
            }) patterns
          ) routes
        );

        # Order of the picker list; profiles not named here come after.
        profile_order = map (b: browsers.${b}) [
          "zen"
          "brave"
          "chromium"
          "firefoxWork"
          "vivaldi"
        ];

        hidden_apps = [ ];
        hidden_profiles = [
          "firefox#default"
          "firefox#default-release"
        ];

        ui = {
          show_hotkeys = true;
          quit_on_lost_focus = false;
          theme = "Auto";
        };
        # Match and open the real target of Outlook Safe Links and
        # l.messenger.com redirects, not the redirector.
        behavior.unwrap_urls = true;
      };

      configFile = (pkgs.formats.json { }).generate "browsers-config.json" settings;
      desktopFile = "software.Browsers.desktop";
    in
    lib.mkMerge [
      {
        home.packages = [ pkgs.browsers ];

        # Copied rather than linked: Browsers rewrites config.json whenever
        # something changes in its UI, and panics if the file isn't writable.
        # Changes made there last until the next switch.
        home.activation.browsersPickerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run install -Dm644 ${configFile} ${lib.escapeShellArg "${config.xdg.configHome}/software.Browsers/config.json"}
        '';

        # Make Browsers the default browser again on every switch, in case
        # something has claimed http/https since. Only those two lines of
        # mimeapps.list are touched: xdg.mimeApps would take over the whole
        # file read-only and stop apps from registering their own handlers.
        home.activation.browsersPickerDefault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${pkgs.xdg-utils}/bin/xdg-mime default ${desktopFile} x-scheme-handler/http x-scheme-handler/https
        '';
      }

      # KDE apps open web links with kdeglobals' BrowserApplication before
      # looking at mimeapps.list, and System Settings writes it when a
      # default browser is picked there. plasma-manager resets it on switch.
      (lib.optionalAttrs (options.programs ? plasma) {
        programs.plasma.configFile.kdeglobals.General.BrowserApplication = desktopFile;
      })
    ];
}
