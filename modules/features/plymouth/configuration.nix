/**
  Graphical boot splash.

  Plymouth draws over the console from early initrd until the login manager
  takes over, which also means the LUKS passphrase prompt becomes a proper
  graphical dialog instead of a bare text prompt. That upgrade needs systemd
  in the initrd — the old scripted initrd asks for the passphrase itself and
  only gets Plymouth's plain text mode.

  Plymouth is a cosmetic layer over the console, not a replacement for it, so
  it only looks clean if the kernel and udev stop writing there while it draws.
  Hence “quiet” and the log level parameters below; kernel messages still go to
  the journal, they just no longer punch through the splash.
*/
{ ... }:
{
  flake.nixosModules.plymouthBoot =
    { lib, pkgs, ... }:
    {
      boot.plymouth = {
        enable = true;
        # Stick to themes built on the “two-step” plugin. The alternative is the
        # *script* engine, which lays out in one coordinate space spanning every
        # head and sized to the widest one. KDE's Breeze — the obvious match for
        # the Plasma login manager — positions the passphrase box exactly once
        # there, but recomputes the row of bullets on every keystroke. Plug in an
        # external display and its mode set lands between those two moments, the
        # shared coordinate space resizes, and the bullets end up drawn beside
        # the box rather than inside it. two-step instead lays out per display
        # and draws box and bullets as a single widget, so they cannot drift
        # apart.
        #
        # nixos-bgrt spins the NixOS logo on top of the image the firmware
        # already put on screen (this machine has a 528 KB one in
        # /sys/firmware/acpi/bgrt), which with the boot menu skipped below makes
        # for a seamless handover from firmware to splash.
        theme = "nixos-bgrt";
        themePackages = [ pkgs.nixos-bgrt-plymouth ];
      };

      boot.initrd.systemd.enable = true;

      boot.consoleLogLevel = 0;
      boot.initrd.verbose = false;
      boot.kernelParams = [
        "quiet"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        # Otherwise a text cursor blinks on top of the splash.
        "vt.global_cursor_default=0"
      ];

      # Go straight to the splash rather than sitting on the systemd-boot menu.
      # Holding Space during boot still brings the menu up when it is needed.
      boot.loader.timeout = lib.mkDefault 0;
    };
}
