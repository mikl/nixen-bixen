/**
  Desktop launchers for web apps, opened as app-mode windows in the "Reload"
  Brave profile (kept separate from the main profile so PWA sessions don't
  share cookies with regular browsing) with a pinned SVG icon.
*/
{ ... }:
{
  flake.homeModules.linuxDesktopPwas =
    { pkgs, lib, ... }:
    let
      # Chromium selects profiles by their on-disk directory name, not their
      # display name. Using a fixed, meaningful name here (rather than the
      # auto-assigned "Profile N") keeps this declaration valid across
      # machines: Brave creates a fresh "Reload" profile on first launch
      # wherever one doesn't already exist yet.
      reloadProfileDirectory = "Reload";

      mkPwaDesktopItem =
        {
          name,
          desktopName,
          url,
          iconUrl,
          iconHash,
          genericName ? null,
          categories ? [ "Network" ],
          profileDirectory ? null,
        }:
        let
          wmClass = builtins.replaceStrings [ " " ] [ "" ] desktopName;
          # Desktop Entry Exec quoting (XDG spec) uses double quotes, not
          # POSIX shell quoting, so lib.escapeShellArg doesn't apply here.
          profileFlag = lib.optionalString (
            profileDirectory != null
          ) " --profile-directory=\"${profileDirectory}\"";
        in
        pkgs.makeDesktopItem {
          inherit
            name
            desktopName
            genericName
            categories
            ;
          exec = "${lib.getExe pkgs.brave-origin} --app=${url} --class=${wmClass}${profileFlag}";
          icon = pkgs.fetchurl {
            url = iconUrl;
            hash = iconHash;
          };
          startupWMClass = wmClass;
        };
    in
    {
      home.packages = [
        (mkPwaDesktopItem {
          name = "harvest-pwa";
          desktopName = "Harvest";
          genericName = "Time Tracking";
          url = "https://reload.harvestapp.com/";
          iconUrl = "https://id.getharvest.com/favicon.svg";
          iconHash = "sha256-P25jqAr7JRHyl52Omxse1yoXGkThMRk8lCGCbMoUpGA=";
          profileDirectory = reloadProfileDirectory;
        })
        (mkPwaDesktopItem {
          name = "gmail-pwa";
          desktopName = "Gmail";
          genericName = "Email";
          url = "https://mail.google.com/mail/";
          iconUrl = "https://www.gstatic.com/images/branding/productlogos/gmail_2026/v2/web/192px.svg";
          iconHash = "sha256-CiQhMUJLeWomJHqO3UHWb6KU2m0XeJdSahm36Brt/bg=";
          profileDirectory = reloadProfileDirectory;
        })
        (mkPwaDesktopItem {
          name = "google-calendar-pwa";
          desktopName = "Google Calendar";
          genericName = "Calendar";
          url = "https://calendar.google.com/calendar/";
          iconUrl = "https://www.gstatic.com/images/branding/productlogos/calendar_2026/v2/web/192px.svg";
          iconHash = "sha256-f1XNh3siYZSBaNs9LpRowM8/B3ZniUiehToPmTHf+Oo=";
          profileDirectory = reloadProfileDirectory;
        })
        (mkPwaDesktopItem {
          name = "google-meet-pwa";
          desktopName = "Google Meet";
          genericName = "Video Conferencing";
          url = "https://meet.google.com/";
          iconUrl = "https://www.gstatic.com/images/branding/productlogos/meet_2026/v2/web/192px.svg";
          iconHash = "sha256-ri6GqgCf1+GVIIK/99T6nsqPRf9G0CmIANU8XWvcs7Q=";
          profileDirectory = reloadProfileDirectory;
        })
      ];
    };
}
