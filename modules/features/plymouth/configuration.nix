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
    { lib, ... }:
    {
      boot.plymouth = {
        enable = true;
        # NixOS ships a NixOS-branded build of KDE's Breeze theme and wires it
        # up automatically when the theme is named “breeze”. It matches the
        # Plasma login manager that takes over right afterwards.
        theme = "breeze";
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
