/**
  Home manager config for Tarsonis. Just there to select which features we want.
*/
{ self, inputs, ... }:
{
  flake.homeModules.tarsonis =
    { pkgs, ... }:
    {
      imports = [
        inputs.nvf.homeManagerModules.default
        self.homeModules.common
        self.homeModules.devAiHomeManager
        self.homeModules.greylineHomeConfig
        self.homeModules.linuxDesktopBasis
        self.homeModules.linuxDesktopDevelop
        self.homeModules.linuxDesktopEmailClient
        self.homeModules.linuxDesktopKDE
        self.homeModules.linuxDesktopPwas
        self.homeModules.linuxDesktopSyncthing
        self.homeModules.localdevHomeManager
        self.homeModules.neoVimNVF
        self.homeModules.niriHomeManager
      ];

      /**
        Apple Studio Display plus the Framework's internal panel.

        The Studio Display appears as two connectors because it is a tiled 5K
        panel: its EDID carries a DisplayID Tiled Display Topology block
        declaring 2 horizontal tiles of 2560x2880, DP-5 being tile (0,0) and
        DP-6 tile (1,0). That is the pre-DSC way of pushing 5120x2880 over
        DisplayPort, and the kernel dutifully exposes one connector per tile.
        The link here does negotiate DSC, so tile 0 alone offers the whole
        5120x2880 image and tile 1 carries nothing — hence 5K on DP-5 and
        `off` on DP-6.

        The two tiles share byte-identical identification (Apple / model 44602
        / serial 0x2D5687B6 / "StudioDisplay"), so niri's `make model serial`
        matching cannot separate them and the connector name is the only
        discriminator left. Those names are stable — amdgpu creates all eight
        DP connectors at probe, one per DisplayPort tunnel the four USB-C ports
        can carry, and the display simply opens two of them — but they name a
        port, not a display. Moving the cable to another USB-C port will land
        the tiles on a different pair, and these rules then want updating.

        Positions are logical (post-scale) pixels. The Studio Display is
        2560x1440 logical at 2x, and the internal panel 1694x1129 at 1.7, hence
        the -1695 that parks it just off the primary's left edge.
      */
      local.niri.outputs = ''
        output "DP-5" {
            mode "5120x2880@60"
            scale 2
            position x=0 y=0
        }

        output "DP-6" {
            off
        }

        output "eDP-1" {
            mode "2880x1920@120"
            scale 1.7
            position x=-1695 y=0
        }
      '';

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
