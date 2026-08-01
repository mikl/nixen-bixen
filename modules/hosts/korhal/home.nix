/**
  Home manager config for Korhal. Runs as part of the nix-darwin configuration,
  so the username and home directory come from there.
*/
{ self, inputs, ... }:
{
  flake.homeModules.korhalHomeManager =
    { pkgs, ... }:
    {
      imports = [
        inputs.nvf.homeManagerModules.default
        self.homeModules.common
        self.homeModules.localdevHomeManager
        self.homeModules.luxusShellHomeManager
        self.homeModules.neoVimNVF
      ];

      home.stateVersion = "25.11";

      home.packages = [
        pkgs._1password-cli
        pkgs.autoconf
        pkgs.btop
        pkgs.curl
        # Homebrew’s macos-trash.
        pkgs.darwin.trash
        pkgs.mas
        # Provides certutil, which mkcert needs to reach browser trust stores.
        # It lives in the “tools” output; the default one has no binaries.
        pkgs.nss.tools
        pkgs.slack-cli
        pkgs.switchaudio-osx
      ];

      programs.nh = {
        enable = true;
        darwinFlake = "/Volumes/Code/Nix/nixen-bixen#korhal";
      };

      programs.tealdeer.enable = true;

      # This currently generates an invalid launchd file, so disable for now.
      programs.tealdeer.enableAutoUpdates = false;

      # For https://github.com/AsimovMac/asimov
      xdg.configFile."asimov/config".text = ''
        [sentinels]
        extra = .devenv devenv.nix

        [fixed_dirs]
        enabled = true
        extra = ~/Library/Caches
        extra = ~/.local/share/gem
        extra = ~/.local/share/mise/downloads
        extra = ~/.local/share/mise/installs
        extra = ~/.local/share/pnpm/store
        [scan]
        extra = /Volumes/Code
      '';
    };
}
