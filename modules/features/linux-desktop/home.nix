{ self, inputs, ... }:
{
  flake.homeModules.linuxDesktopMikl =
    { pkgs, ... }:
    {
      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.11"; # Please read the comment before changing.

      home.packages = with pkgs; [
        lazydocker
        nixfmt
        tealdeer
      ];

      programs.fastfetch.enable = true;
      programs.lazygit.enable = true;
      programs.neovide.enable = true;
    };
}
