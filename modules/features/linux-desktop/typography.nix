/**
  Typography set-up for Linux desktop.
*/
{ ... }:
{
  flake.homeModules.linuxDesktopTypography =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        geist-font
        (pkgs.iosevka-bin.override { variant = "Etoile"; })
        (pkgs.iosevka-bin.override { variant = "Slab"; })
        (pkgs.iosevka-bin.override { variant = "SGr-IosevkaTermSlab"; })
        iosevka-bin
        lato
        victor-mono
      ];
    };
}
