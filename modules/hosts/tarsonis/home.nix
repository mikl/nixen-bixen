{ self, inputs, ... }:
{
  flake.homeModules.tarsonisHomeManager =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.localdevHomeManager
        self.homeModules.luxusShellHomeManager
      ];

      home.username = "mikl";
      home.homeDirectory = "/home/mikl";
      home.stateVersion = "25.11";

      home.packages = [
        pkgs.btop
        pkgs.nixfmt
      ];

      programs.fastfetch.enable = true;
      programs.home-manager.enable = true;

      programs.nh = {
        enable = true;
        homeFlake = "/home/mikl/Projects/Nix/nixen-bixen#korhal";
      };
      programs.tealdeer.enable = true;
    };
}
