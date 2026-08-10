/**
  Work around the Framework 13 (AMD AI 300 series) fingerprint reader
  vanishing after a few sleep/wake cycles.

  The Goodix fingerprint reader (USB 27c6:609c) lives alone behind its own
  dedicated AMD xHCI controller function (PCI 1022:1128). On resume this
  controller sometimes fails its USB core resume callback:

    usb 3-1: PM: dpm_run_callback(): usb_dev_resume returns -22
    usb 3-1: PM: failed to resume async: error -22
    usb 3-1: USB disconnect, device number 2

  ...and the device never comes back, since nothing re-triggers
  enumeration for a fixed, non-hotpluggable internal device. Unbinding and
  rebinding the PCI function forces the controller to fully reinitialize,
  which re-enumerates the reader. fprintd is D-Bus-activated and exits when
  idle, so it needs no restart — it just picks up the device next time PAM
  asks it to authenticate.
*/
{ ... }:
{
  flake.nixosModules.frameworkFingerprintResumeFix =
    { pkgs, ... }:
    {
      systemd.services.framework-fingerprint-resume-fix = {
        description = "Re-enumerate the Framework fingerprint reader's USB controller after resume";

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

          # Let the bus settle after resume before poking the controller.
          sleep 2

          for dev in /sys/bus/pci/devices/*; do
            [ -e "$dev/vendor" ] || continue
            [ "$(cat "$dev/vendor")" = "0x1022" ] || continue
            [ "$(cat "$dev/device")" = "0x1128" ] || continue

            id="$(basename "$dev")"
            echo "Re-enumerating fingerprint reader's USB controller at $id"
            echo "$id" > /sys/bus/pci/drivers/xhci_hcd/unbind || true
            sleep 1
            echo "$id" > /sys/bus/pci/drivers/xhci_hcd/bind   || true
          done
        '';
      };
    };
}
