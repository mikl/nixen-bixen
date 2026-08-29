{ self, ... }:
{
  flake.homeModules.luxusShellHomeManager =
    { pkgs, ... }:
    {
      imports = [
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
        # Disable fish greeting.
        interactiveShellInit = ''
          set fish_greeting ""
        '';
      };

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        changeDirWidget.command = "fd --type d";
        defaultCommand = "fd --type f";
        fileWidget.command = "fd --type f";
      };

      programs.ripgrep.enable = true;

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [
          "--cmd j"
        ];
      };
    };
}
