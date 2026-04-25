{ inputs, ... }:
{
  flake.homeConfigurations."mikl@korhal" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
    modules = [ ../../homes/korhal.nix ];
  };
}
