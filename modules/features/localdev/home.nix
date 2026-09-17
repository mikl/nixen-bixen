{ self, inputs, ... }:
{
  flake.homeModules.localdevHomeManager =
    { pkgs, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    {
      imports = [
        self.homeModules.gitHomeConfig
        self.homeModules.jujutsuHomeConfig
      ];

      # Add NVM stub files for projects that assume NVM is available.
      home.file.".nvm/nvm.sh" = {
        executable = true;
        force = true;
        text = ''
          #!/usr/bin/env bash

          echo "Not using NVM, using Nix instead."

          alias nvm='echo'
        '';
      };

      home.packages = with pkgs; [
        caligula # Disk imaging TUI.
        cloc
        gh
        go-task
        httpie
        just
        jq
        mkcert
        nodejs_24 # General installation for use outside devenvs.
        nil # Language server for Nix.
        nixfmt
        ruby # Shadows macOS’ ancient system Ruby, which predates XDG support.
        wakeonlan
      ];

      programs.devenv = {
        enable = true;
        package = unstable.devenv;
        # No auto-activation hook: it spawns a nested interactive fish on its
        # own pty for every prompt inside an allowed project, and cd-ing out
        # deadlocks - the inner shell exits while fish's per-prompt terminal
        # queries (OSC 11, CPR, DA1) are still in flight, `devenv shell` never
        # reaps it, and the outer shell waits forever. direnv below covers the
        # same ground without a nested shell; give projects an `.envrc` with
        # `eval "$(devenv direnvrc)"` and `use devenv`.
        enableFishIntegration = false;
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        # Starship prompt shows direnv status, so no need for log output on every load.
        silent = true;
      };

      programs.gitui.enable = true;

      programs.lazygit = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.lazydocker.enable = true;
    };
}
