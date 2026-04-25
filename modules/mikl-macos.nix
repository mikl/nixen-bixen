{ den, ... }:
{
  # user aspect
  den.aspects.mikl-macos = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "fish")
    ];

    homeManager =
      { pkgs, ... }:
      {
        # home.username = "mikl";
        # home.homeDirectory = "/Users/mikl";

        home.packages = [
          pkgs.go-task
          pkgs.httpie
          pkgs.just
          pkgs.kamal
          pkgs.nixfmt
        ];

        home.shellAliases = {
          ls = "eza";
          ll = "eza -l";
          la = "eza -lAh";
          l = "eza -CF";
          cat = "bat --plain";
          ni = "nvim";
          vi = "nvim";
          lg = "lazygit";
        };

        programs.home-manager.enable = true;

        programs.bat = {
          enable = true;
          config.paging = "never";
        };

        programs.btop.enable = true;
        programs.eza = {
            enable = true;
            enableFishIntegration = true;
            extraOptions = [
              "--group-directories-first"
            ];
          };

          programs.fastfetch.enable = true;

          programs.fish = {
            enable = true;
          };

          programs.lazydocker.enable = true;

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

          programs.tealdeer.enable = true;

          programs.zoxide = {
            enable = true;
            enableFishIntegration = true;
            options = [
              "--cmd j"
            ];
          };
      };
  };
}
