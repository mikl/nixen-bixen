/**
  Home manager config for Eidolon. Just there to select which features we want.
*/
{ self, inputs, ... }:
{
  flake.homeModules.eidolon =
    { pkgs, ... }:
    {
      imports = [
        inputs.nvf.homeManagerModules.default
        self.homeModules.browsersPwas
        self.homeModules.common
        self.homeModules.devAiHomeManager
        self.homeModules.linuxDesktopBasis
        self.homeModules.linuxDesktopKDE
        self.homeModules.linuxDesktopPlasma
        self.homeModules.linuxDesktopSyncthing
        self.homeModules.localdevHomeManager
        self.homeModules.neoVimNVF
        self.homeModules.niriHomeManager
      ];

      # 4K LG TV, matched by EDID make/model/serial so the rule still applies
      # if the cable moves to a different port. Its physical size is large
      # enough that niri would guess scale 1; this forces 2x instead.
      local.niri.outputs = ''
        output "LG Electronics LG TV 0x01010101" {
            scale 2
        }
      '';

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
