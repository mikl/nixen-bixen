/**
  Konfiguration for KDE desktop environment.
*/
{ ... }:
{
  flake.homeModules.linuxDesktopEmailClient =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        protonmail-bridge
        protonmail-bridge-gui
        protonmail-desktop
        thunderbird
      ];
    };
}
