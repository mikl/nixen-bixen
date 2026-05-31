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
      };

      programs.lazygit = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.lazydocker.enable = true;
    };
}
