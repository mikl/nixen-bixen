/**
  Typography set-up for Linux desktop.
*/
{ self, inputs, ... }:
{
  flake.homeModules.linuxDesktopTypography =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        (pkgs.iosevka-bin.override { variant = "Etoile"; })
        (pkgs.iosevka-bin.override { variant = "Slab"; })
        (pkgs.iosevka-bin.override { variant = "SGr-IosevkaTermSlab"; })
        iosevka-bin
        lato
        victor-mono
      ];
    };
}
