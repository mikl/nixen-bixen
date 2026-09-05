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
