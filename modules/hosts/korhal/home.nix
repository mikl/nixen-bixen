{ self, ... }:
{
  flake.homeModules.korhalHomeManager =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.localdevHomeManager
        self.homeModules.luxusShellHomeManager
        self.homeModules.neoVimNVF
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

      # This currently generates an invalid launchd file, so disable for now.
      programs.tealdeer.enableAutoUpdates = false;

      # For https://github.com/AsimovMac/asimov
      xdg.configFile."asimov/config".text = ''
        [sentinels]
        extra = .devenv devenv.nix

        [fixed_dirs]
        enabled = true
        extra = ~/Library/Caches
        extra = ~/.local/share/gem
        extra = ~/.local/share/mise/downloads
        extra = ~/.local/share/mise/installs
        extra = ~/.local/share/pnpm/store
      '';
    };
}
