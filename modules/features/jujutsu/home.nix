{ ... }:
{
  flake.homeModules.jujutsuHomeConfig =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        blazingjj
        gg
        jjui
        lazyjj
      ];

      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            email = "mikkel@hoegh.org";
            name = "Mikkel T. Høgh";
          };
        };
      };
    };
}
