/**
  Work around a QMK/USB resume glitch on the Ergodox EZ.

  When the machine wakes from sleep, the Ergodox EZ (USB 3297:4975)
  occasionally re-attaches reporting a phantom held key (typically Enter)
  before its HID state re-syncs. Forcing a USB re-enumeration of just that
  device after resume makes the HID driver re-read key state (all keys up),
  which releases the stuck key.
*/
{ ... }:
{
  flake.nixosModules.ergodoxResumeFix =
    { pkgs, ... }:
    {
      systemd.services.ergodox-resume-fix = {
        description = "Re-enumerate Ergodox EZ after resume to clear phantom held keys";

        # Ordering the service *after* the sleep targets makes it run on
        # resume: systemd-suspend.service blocks for the duration of the
        # actual suspend, so anything After= these targets starts on wake.
        after = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "suspend-then-hibernate.target"
        ];
        wantedBy = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "suspend-then-hibernate.target"
        ];

        path = [ pkgs.coreutils ];
        serviceConfig.Type = "oneshot";

        script = ''
          set -u

          # Let the USB bus settle after resume before poking the device.
          sleep 2

          for dev in /sys/bus/usb/devices/*; do
            [ -e "$dev/idVendor" ] || continue
            [ "$(cat "$dev/idVendor")"  = "3297" ] || continue
            [ "$(cat "$dev/idProduct")" = "4975" ] || continue

            id="$(basename "$dev")"
            echo "Re-enumerating Ergodox EZ at $id"
            echo "$id" > /sys/bus/usb/drivers/usb/unbind || true
            sleep 1
            echo "$id" > /sys/bus/usb/drivers/usb/bind   || true
          done
        '';
      };
    };
}
