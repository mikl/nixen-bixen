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
        ghostty.terminfo
        git
        wget
      ];

      # Enable flakes.
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # TEMPORARY: the pnpm deps hash for typescript-language-server 6.0.2
      # is stale in nixpkgs-weekly 7fd4004d (Oct 11); nixpkgs-unstable has
      # since corrected it. Remove once nixpkgs-weekly catches up.
      nixpkgs.overlays = [
        (final: prev: {
          typescript-language-server = prev.typescript-language-server.overrideAttrs (old: {
            pnpmDeps = old.pnpmDeps.overrideAttrs {
              outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
            };
          });
        })
      ];

      # The bare essentials for a decent Vim experience.
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        configure = {
          customLuaRC = ''
            vim.opt.expandtab = true
            vim.opt.shiftwidth = 2
            vim.opt.tabstop = 2
            vim.opt.smartindent = true
            vim.opt.number = true
            vim.opt.relativenumber = true
          '';
        };
      };

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 7d --keep 7 --keep-one";
      };
    };
}
