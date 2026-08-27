{ ... }:
{
  flake.homeModules.ghosttyHomeConfig =
    { pkgs, ... }:
    {
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

          # niri sizes the window: a window-rule gives it a 2/3-width column,
          # which a maximize request here would override.
          window-decoration = false;

          keybind = [
            # Make shift-insert do regular paste.
            "shift+insert=paste_from_clipboard"
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
    };
}
