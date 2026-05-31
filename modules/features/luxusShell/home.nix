{ ... }:
{
  flake.homeModules.luxusShellHomeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        dysk
        ncdu # TUI-alternative to du.
      ];

      home.shell.enableFishIntegration = true;

      home.shellAliases = {
        # Replace ls with eza.
        ls = "eza";
        ll = "eza -l";
        la = "eza -lAh";
        l = "eza -CF";

        # Replace cat with bat.
        cat = "bat --plain";

        # NeoVim shortcuts.
        ni = "nvim";
        vi = "nvim";
      };

      # Modern replacement for cat.
      programs.bat = {
        enable = true;
        config = {
          paging = "never";
        };
      };

      # Modern replacement for ls.
      programs.eza = {
        enable = true;
        enableFishIntegration = true;
        extraOptions = [
          "--group-directories-first"
        ];
      };

      # Modern replacement for find.
      programs.fd.enable = true;

      programs.fish = {
        enable = true;
        # Disable fish greeting.
        interactiveShellInit = ''
          set fish_greeting ""
        '';
      };

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        changeDirWidgetCommand = "fd --type d";
        defaultCommand = "fd --type f";
        fileWidgetCommand = "fd --type f";
      };

      programs.ripgrep.enable = true;

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          aws.disabled = true;
          azure.disabled = true;
          cobol.disabled = true;
          direnv.disabled = false;
          status.disabled = false;
        };
      };

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [
          "--cmd j"
        ];
      };
    };
}
