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
        self.homeModules.devAiHomeManager
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
        # The launchd agent calls the binary by store path, so this is only here
        # to get the syncthing CLI and its man pages onto PATH.
        pkgs.syncthing
      ];

      # Run Syncthing via home manager, but avoid configuring it, to keep the old
      # configuration from before Nix.
      services.syncthing.enable = true;

      programs.fish = {
        # Homebrew’s own shellenv prepends its bin directories, which shadows the
        # Nix build of anything installed in both places. Set the variables it
        # exports, but keep its paths at the end of PATH. fish reads conf.d
        # before config.fish, and shellInitLast is the tail of config.fish, so
        # this has the final say.
        shellInitLast = ''
          set -gx HOMEBREW_PREFIX /opt/homebrew
          set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
          set -gx HOMEBREW_REPOSITORY /opt/homebrew

          set -l brewPaths /opt/homebrew/bin /opt/homebrew/sbin
          set -l keptPaths
          for entry in $PATH
              contains -- $entry $brewPaths; or set -a keptPaths $entry
          end
          set -gx PATH $keptPaths $brewPaths

          not contains -- /opt/homebrew/share/man $MANPATH; and set -gx MANPATH $MANPATH /opt/homebrew/share/man
        '';

        # Was set by the fish_frozen_key_bindings.fish snippet that fish wrote
        # when it migrated the variable out of universal scope.
        interactiveShellInit = ''
          set -g fish_key_bindings fish_vi_key_bindings
        '';
      };

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
