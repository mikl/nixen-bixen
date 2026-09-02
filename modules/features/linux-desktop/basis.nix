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

        # hicolor is the mandatory fallback icon theme, and its index.theme is
        # what tells a lookup which size subdirectories exist. NixOS ships one
        # in the system profile, but the per-user profile only gets the
        # `share/icons/hicolor/<size>/apps` trees from the apps installed here
        # — no index. Noctalia's resolver walks every base dir, and for a
        # hicolor root without an index it probes a hardcoded shortlist
        # (scalable, 256, 128, 64, 48, 32) that omits 512x512. Apps that ship
        # only a 512px PNG — Zed, Zulip, Todoist — then have no findable icon
        # in the launcher. Installing the theme here drops the real index next
        # to those trees so all sizes are enumerated.
        hicolor-icon-theme
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
        # Signal is an Electron app, so Chromium picks the secret-storage
        # backend from XDG_CURRENT_DESKTOP: under Plasma that resolves to
        # kwallet6, but Niri is an unknown desktop and Chromium falls back to
        # the plaintext “basic” store. Signal then sees the backend change
        # and refuses to open a database it can no longer decrypt. Name the
        # backend explicitly so both sessions agree — kwalletd6 is DBus-
        # activatable and is these days just a shim in front of ksecretd.
        (symlinkJoin {
          name = "signal-desktop-kwallet";
          paths = [ signal-desktop ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/signal-desktop --add-flags "--password-store=kwallet6"
          '';
        })
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
