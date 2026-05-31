{ self, inputs, ... }:
{
  flake.homeModules.localdevHomeManager =
    { pkgs, ... }:
    {
      home.shellAliases = {
        lg = "lazygit";
      };

      home.packages = [
        pkgs.go-task
        pkgs.httpie
        pkgs.just
      ];

      programs.lazygit = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.lazydocker.enable = true;
    };
}
