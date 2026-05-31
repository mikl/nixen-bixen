{ self, ... }:
{
  flake.homeModules.korhalHomeManager =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.localdevHomeManager
        self.homeModules.luxusShellHomeManager
      ];

      home.username = "mikl";
      home.homeDirectory = "/Users/mikl";
      home.stateVersion = "25.11";

      home.packages = [
        pkgs.btop
        pkgs.nixfmt
      ];

      programs.fastfetch.enable = true;
      programs.home-manager.enable = true;

      programs.nh = {
        enable = true;
        homeFlake = "/Volumes/Code/Nix/nixen-bixen#korhal";
      };

      programs.tealdeer.enable = true;
    };
}
