/**
  Shared basis for all Linux desktop configurations.
*/
{ self, inputs, ... }:
{
  flake.homeModules.linuxDesktopBasis =
    { pkgs, ... }:
    {
      imports = [
        inputs.zen-browser.homeModules.beta
        self.homeModules.dictionaries
        self.homeModules.ghosttyHomeConfig
        self.homeModules.linuxDesktopTypography
        self.homeModules.luxusShellHomeManager
      ];

      home.packages = with pkgs; [
        aha # For displaying network interfaces in the KDE Info Center.
        obsidian
        jellyfin-desktop
        tealdeer
        todoist-electron
        vlc
        wl-clipboard # Wayland clipboard; Neovim prefers wl-copy/wl-paste over xclip on Wayland.
        xclip
        wavemon

        # Browsers.
        brave
        browsers
        firefox

        # Communication.
        signal-desktop
        zapzap # Whatsapp desktop client.
        zulip
      ];

      programs.neovide.enable = true;

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = false;
      };
    };
}
