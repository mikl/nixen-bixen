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
        declaring 2 horizontal tiles of 2560x2880. That is the pre-DSC way of
        pushing 5120x2880 over DisplayPort, and the kernel exposes one
        connector per tile. This link does negotiate DSC, so tile 0 alone
        carries the whole image and tile 1 carries nothing.

        Both tiles present byte-identical EDID, and niri refuses to let two
        outputs share an identity: on finding a duplicate it strips make,
        model and serial from the later connector (`tty.rs`, "duplicates
        make/model/serial of existing connector, unnaming"). The surviving
        tile keeps the Apple identity, so the rule below matches it by EDID
        and holds whichever USB-C port the cable is in. The stripped tile is
        left to niri-arrange-displays, which switches off outputs it cannot
        identify — nothing in the config can name one, since matching by
        make/model/serial is exactly what the stripping removes.

        Both outputs are named by EDID rather than connector. For the panel
        that buys nothing over eDP-1, which never moves — but it does mean a
        Framework mainboard swap keeps the rule, while a screen replacement
        would need the new model number here.

        Positions are logical (post-scale) pixels: the Studio Display is
        2560x1440 at 2x, the internal panel 1694x1129 at 1.7, hence the -1695
        that parks it just off the primary's left edge.
      */
      local.niri.outputs = ''
        output "Apple Computer Inc StudioDisplay 0x2D5687B6" {
            mode "5120x2880@60"
            scale 2
            position x=0 y=0
            focus-at-startup
        }

        // The panel reports no serial, and niri substitutes "Unknown" for the
        // missing field rather than dropping it.
        output "BOE NE135A1M-NY1 Unknown" {
            mode "2880x1920@120"
            scale 1.7
            position x=-1695 y=0
        }
      '';

      /**
        The one kwinrulesrc rule that pinned a screen rather than a desktop,
        so it stays here where the connector names mean something.

        KWin recorded `screen=2` for Brave Origin, from a larger monitor setup
        than this one — the built-in panel is what "second screen" means today.
        Two further screen-pinned rules are left out for want of anything to
        map them onto: Chromium's `screen=1`, and the Google Meet PWA's
        `screen=3`.
      */
      local.niri.extraConfig = ''
        window-rule {
            match app-id=r#"(?i)^brave-origin$"#
            open-on-output "BOE NE135A1M-NY1 Unknown"
            open-maximized true
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
