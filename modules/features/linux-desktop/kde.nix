/**
  Konfiguration for KDE applications.

  All of these are standalone and run fine under Niri; the Plasma-session-only
  pieces live in plasma.nix.

  niri/configuration.nix exists partly to serve these: it points the
  FileChooser portal at the KDE backend and sets `qt.platformTheme = "kde"` so
  Dolphin and Okular look and behave the way they do under Plasma.
*/
{ ... }:
{
  flake.homeModules.linuxDesktopKDE =
    { pkgs, ... }:
    {
      home.packages =
        (with pkgs.kdePackages; [
          akregator
          alligator
          ark # For extraction/compression in Dolphin.
          dolphin
          dolphin-plugins
          filelight
          gwenview
          kompare
          krdc
          okular
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
