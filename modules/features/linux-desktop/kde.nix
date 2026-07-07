/**
  Konfiguration for KDE desktop environment.
*/
{ ... }:
{
  flake.homeModules.linuxDesktopKDE =
    { pkgs, ... }:
    {
      home.packages = with pkgs.kdePackages; [
        akregator
        alligator
        aurorae
        dolphin
        dolphin-plugins
        dragon # Media player.
        falkon
        filelight
        gwenview
        kate
        kdf
        kompare
        krdc
        marble
        ocean-sound-theme
        okular
        oxygen
        oxygen-icons
        oxygen-sounds
        plasma-thunderbolt
        spectacle
      ];
    };
}
