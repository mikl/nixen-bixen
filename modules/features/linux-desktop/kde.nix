/**
  Konfiguration for KDE desktop environment.
*/
{ self, inputs, ... }:
{
  flake.homeModules.linuxDesktopKDE =
    { pkgs, ... }:
    {
      home.packages = with pkgs.kdePackages; [
        dolphin
        gwenview
        kate
        krdc
        marble
        okular
        plasma-thunderbolt
        spectacle
      ];
    };
}
