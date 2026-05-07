{ self, inputs, ... }:
{
  flake.homeModules.korhalHomeManager =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.luxusShellHomeManager
      ];

      home.username = "mikl";
      home.homeDirectory = "/Users/mikl";
      home.stateVersion = "25.11";

      home.packages = [
        pkgs.btop
        pkgs.go-task
        pkgs.httpie
        pkgs.just
        pkgs.kamal
        pkgs.nixfmt
      ];

      programs.fastfetch.enable = true;
      programs.home-manager.enable = true;

      programs.nh = {
        enable = true;
        homeFlake = "/Volumes/Code/Nix/nixen-bixen#korhal";
      };

      programs.lazydocker.enable = true;
      programs.tealdeer.enable = true;
    };
}
