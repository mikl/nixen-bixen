/**
  Desktop launchers for web apps, opened as app-mode windows in Brave with a
  pinned SVG icon.
*/
{ ... }:
{
  flake.homeModules.linuxDesktopPwas =
    { pkgs, lib, ... }:
    let
      mkPwaDesktopItem =
        {
          name,
          desktopName,
          url,
          iconUrl,
          iconHash,
          genericName ? null,
          categories ? [ "Network" ],
        }:
        let
          wmClass = builtins.replaceStrings [ " " ] [ "" ] desktopName;
        in
        pkgs.makeDesktopItem {
          inherit
            name
            desktopName
            genericName
            categories
            ;
          exec = "${lib.getExe pkgs.brave-origin} --app=${url} --class=${wmClass}";
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
        })
      ];
    };
}
