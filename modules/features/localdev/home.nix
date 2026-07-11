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
        go-task
        httpie
        just
        jq
      ];

      # Prefer XDG directories for config and data to leave less junk in the home directory.
      home.preferXdgDirectories = true;

      programs.devenv.enable = true;

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        # Starship prompt shows direnv status, so no need for log output on every load.
        silent = true;
      };

      programs.lazygit = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.lazydocker.enable = true;
    };
}
