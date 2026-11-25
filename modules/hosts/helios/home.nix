/**
  Home manager config for Helios. Terminal-only, since the box is headless.
*/
{ self, inputs, ... }:
{
  flake.homeModules.helios =
    { ... }:
    {
      imports = [
        inputs.nvf.homeModules.default
        self.homeModules.common
        self.homeModules.devAiHomeManager
        self.homeModules.localdevHomeManager
        self.homeModules.luxusShellHomeManager
        self.homeModules.neoVimNVF
        self.homeModules.syncthingHomeManager
      ];

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "26.05"; # Please read the comment before changing.
    };
}
