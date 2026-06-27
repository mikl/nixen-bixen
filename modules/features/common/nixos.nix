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

      # Allow non-root users to pass settings to the Nix daemon (needed by devenv).
      nix.settings.trusted-users = [ "root" "mikl" ];

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      programs.nh.enable = true;
  };
}
