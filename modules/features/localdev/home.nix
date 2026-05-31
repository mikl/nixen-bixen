{ ... }:
{
  flake.homeModules.localdevHomeManager =
    { pkgs, ... }:
    {
      home.shellAliases = {
        lg = "lazygit";
      };

      home.packages = with pkgs; [
        go-task
        httpie
        just
        jq
      ];

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
