/**
  Shared basis for all Linux desktop configurations.
*/
{ self, inputs, ... }:
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
        libreoffice-qt
        obsidian
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

        # Apple Music desktop client. Not in nixpkgs, so it comes from its own
        # flake, which repackages the upstream deb inside an FHS environment.
        inputs.sidra.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      programs.neovide.enable = true;
    };
}
