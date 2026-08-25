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
        # "mac", not "mac-iso": the ISO variant moves grave/asciitilde onto
        # <LSGT>, the extra key an ISO board has beside Z, and puts section/
        # plusminus on <TLDE> instead. Neither of these keyboards has an
        # <LSGT>, so that variant leaves no way to type a backtick.
        variant = "mac";
        # Just caps:escape, which is also all Plasma ever applied via
        # kxkbrc. lv3:ralt_switch was redundant, us(mac) already pulling
        # in level3(ralt_switch); terminate:ctrl_alt_bksp bound the X
        # server's Terminate action, which means nothing under Wayland.
        options = "caps:escape";
      };
    };
}
