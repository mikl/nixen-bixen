{ ... }:
{
  flake.nixosModules.keyboard =
    { ... }:
    {
      console.keyMap = "us";

      # Configure keymap in X11
      services.xserver.xkb = {
        model = "pc104alt";
        layout = "us";
        variant = "mac-iso";
        options = "lv3:ralt_switch,terminate:ctrl_alt_bksp,caps:escape";
      };
    };
}
