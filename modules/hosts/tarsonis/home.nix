/**
  Home manager config for Tarsonis. Just there to select which features we want.
*/
{ self, ... }:
{
  flake.homeModules.tarsonis =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.linuxDesktopBasis
        self.homeModules.linuxDesktopDevelop
        self.homeModules.linuxDesktopEmailClient
        self.homeModules.linuxDesktopKDE
        self.homeModules.linuxDesktopSyncthing
        self.homeModules.localdevHomeManager
      ];

      home.packages = with pkgs; [
        # Apple Studio Display brightness control.
        asdbctl
      ];

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.11"; # Please read the comment before changing.
    };
}
