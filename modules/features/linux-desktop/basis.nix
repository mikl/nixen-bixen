/**
  Shared basis for all Linux desktop configurations.
*/
{ self, ... }:
{
  flake.homeModules.linuxDesktopBasis =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.dictionaries
        self.homeModules.ghosttyHomeConfig
        self.homeModules.linuxDesktopTypography
        self.homeModules.luxusShellHomeManager
      ];

      home.packages = with pkgs; [
        aha # For displaying network interfaces in the KDE Info Center.

        jellyfin-desktop
        obsidian
        onlyoffice-desktopeditors
        tealdeer
        todoist-electron
        vlc
        wavemon
        wl-clipboard # Wayland clipboard; Neovim prefers wl-copy/wl-paste over xclip on Wayland.
        xclip

        wireguard-tools

        # Browsers.
        brave-origin
        browsers
        firefox

        # Communication.
        signal-desktop
        zapzap # Whatsapp desktop client.
        zulip
      ];

      programs.neovide.enable = true;
    };
}
