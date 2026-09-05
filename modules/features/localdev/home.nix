{ self, ... }:
{
  flake.homeModules.localdevHomeManager =
    { pkgs, ... }:
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

      home.shellAliases = {
        lg = "lazygit";
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
        wakeonlan
      ];

      programs.devenv = {
        enable = true;
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
