/**
  Konfiguration for KDE desktop environment.
*/
{ self, ... }:
{
  flake.homeModules.linuxDesktopKDE =
    { pkgs, ... }:
    {
      imports = [ self.homeModules.linuxDesktopKwinThirds ];

      home.packages =
        (with pkgs.kdePackages; [
          akregator
          alligator
          ark # For extraction/compression in Dolphin.
          aurorae
          dolphin
          dolphin-plugins
          filelight
          gwenview
          kompare
          krdc
          ocean-sound-theme
          okular
          oxygen
          oxygen-icons
          oxygen-sounds
          plasma-thunderbolt
          spectacle
        ])
        ++ (with pkgs; [
          /**
            Plugins for Ark to support more archive formats.
          */
          p7zip
          unrar # unfreeRedistributable; allowUnfree is on in common/nixos.nix
          unzip
          zip
        ]);
    };
}
