/**
  Common features for NixOS machines.
*/
{ ... }:
{

  flake.nixosModules.common =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [
        btop
        curl
        git
        neovim
        wget
      ];

      # Enable flakes.
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 18d --keep 7 --keep-one";
      };
  };
}
