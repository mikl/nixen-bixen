/**
  Shared basis for all Linux desktop configurations.
*/
{ self, inputs, ... }:
{
  flake.homeModules.linuxDesktopBasis =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.gitHomeConfig
        self.homeModules.linuxDesktopTypography
        self.homeModules.luxusShellHomeManager
      ];

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.11"; # Please read the comment before changing.

      home.packages = with pkgs; [
        go-task
        httpie
        just
        ghostty
        kamal
        lazydocker
        nixfmt
        obsidian
        tealdeer
        todoist-electron
        xclip
        zed-editor

        # Browsers.
        brave
        librewolf
        vivaldi

        # Communication.
        signal-desktop
        zulip
      ];

      programs.fastfetch.enable = true;
      programs.lazygit.enable = true;
      programs.neovide.enable = true;
    };
}
