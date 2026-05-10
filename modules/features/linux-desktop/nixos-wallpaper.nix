{ self, inputs, ... }:
{
  flake.nixosModules.nixOSWallpaper =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs.nixos-artwork.wallpapers; [
        binary-black
        binary-blue
        binary-red
        binary-white
      ];

      environment.pathsToLink = [ "/share/backgrounds/nixos" ];
    };
}
