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
        aha # For displaying network interfaces in the KDE Info Center.
        obsidian
        plex-desktop
        tealdeer
        todoist-electron
        vlc
        xclip
        wavemon

        # Browsers.
        brave
        browsers
        firefox

        # Communication.
        signal-desktop
        #zulip # Disabled due to https://github.com/NixOS/nixpkgs/issues/525631
      ];

      programs.ghostty = {
        enable = true;
        enableFishIntegration = true;
        installBatSyntax = true;
        installVimSyntax = true;
        settings = {
          theme = "Eldritch";
          background-blur = true;
          background-opacity = "0.95";
          font-family = "Iosevka Term Slab";
          font-size = 11;

          # Don’t ask before quitting, just quit.
          confirm-close-surface = false;
          notify-on-command-finish-action = "bell,notify";

          # Inherit working directory for splits only.
          window-inherit-working-directory = false;
          tab-inherit-working-directory = false;
          split-inherit-working-directory = true;

          # Windowless fullscreen, essentially.
          maximize = true;
          window-decoration = false;

          keybind = [
            # macOS style keyboard shortcuts on Linux.
            "super+a=select_all"
            "super+c=copy_to_clipboard"
            "super+d=new_split:right"
            "super+k=clear_screen"
            "super+n=new_window"
            "super+q=quit"
            "super+t=new_tab"
            "super+v=paste_from_clipboard"
            "super+w=close_surface"
            "super+zero=reset_font_size"
            "super+shift+[=previous_tab"
            "super+shift+]=next_tab"
          ];
        };
        themes = {
          # Based on https://github.com/eldritch-theme/ghostty
          Eldritch = {
            background = "212337";
            cursor-color = "37f499";
            foreground = "ebfafa";
            palette = [
              "0=#21222c"
              "1=#f9515d"
              "2=#37f499"
              "3=#e9f941"
              "4=#9071f4"
              "5=#f265b5"
              "6=#04d1f9"
              "7=#ebfafa"
              "8=#7081d0"
              "9=#f16c75"
              "10=#69f8b3"
              "11=#f1fc79"
              "12=#a48cf2"
              "13=#fd92ce"
              "14=#66e4fd"
              "15=#ffffff"
            ];
            selection-background = "bf4f8e";
            selection-foreground = "ebfafa";
          };
        };
      };

      programs.neovide.enable = true;

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = false;
      };
    };
}
