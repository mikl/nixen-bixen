{ self, inputs, ... }:
{
  flake.homeModules.luxusShellHomeManager =
    { pkgs, ... }:
    {
      imports = [
        inputs.marskal-terminal.homeModules.default
        self.homeModules.starship
      ];

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

      programs.fastfetch.enable = true;

      # Modern replacement for find.
      programs.fd.enable = true;

      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          # Disable fish greeting.
          set fish_greeting ""

          # Vim-style keybindings.
          set -g fish_key_bindings fish_vi_key_bindings
        '';
      };

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        changeDirWidget.command = "fd --type d";
        defaultCommand = "fd --type f";
        fileWidget.command = "fd --type f";
      };

      programs.marskal = {
        enable = true;
        settings.server = "https://preview.marskal.app";
        # keychain = false;  # headless: tokens in a file
      };

      programs.mc.enable = true;

      programs.ripgrep.enable = true;

      programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        shellWrapperName = "yy";
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
