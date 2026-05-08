{ self, inputs, ... }:
{
  flake.homeModules.luxusShellHomeManager =
    { pkgs, ... }:
    {
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

      programs.bat = {
        enable = true;
        config = {
          paging = "never";
        };
      };

      programs.eza = {
        enable = true;
        enableFishIntegration = true;
        extraOptions = [
          "--group-directories-first"
        ];
      };

      programs.fish = {
        enable = true;
      };

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        presets = [
          "nerd-font-symbols"
        ];
        settings = {
          aws.disabled = true;
          azure.disabled = true;
          cobol.disabled = true;
          docker_context.disabled = true;
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
