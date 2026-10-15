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

      # TEMPORARY: breakpad fails to link with binutils 2.46 (pulled in by
      # protonmail-bridge-gui via sentry-native). Fixed upstream in
      # NixOS/nixpkgs#569323; remove once nixpkgs-weekly includes it, at
      # which point this patch will fail to apply twice.
      nixpkgs.overlays = [
        (final: prev: {
          breakpad = prev.breakpad.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./breakpad-fix-vtable-link.patch ];
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
