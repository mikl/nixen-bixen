/**
  Home manager config for Eidolon. Just there to select which features we want.

  Eidolon is headless, so this is the same shape as Korhal's home: shell, dev
  tooling and editor, no GUI applications. luxusShellHomeManager is imported
  directly because it used to arrive via linuxDesktopBasis, which is gone.
*/
{ self, inputs, ... }:
{
  flake.homeModules.eidolon =
    { ... }:
    {
      imports = [
        inputs.nvf.homeManagerModules.default
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
      home.stateVersion = "25.11"; # Please read the comment before changing.
    };
}
