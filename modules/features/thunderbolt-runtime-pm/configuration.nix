/**
  Keep the USB4 PCIe paths out of runtime suspend.

  The Studio Display does not just carry pixels: Thunderbolt tunnels PCIe, so
  the display grafts a real PCIe device onto this machine's bus — an Intel
  JHL7440 (Titan Ridge) xHCI controller carrying the display's USB hubs,
  webcam and speakers. It sits behind PCIe bridge 0000:02:04.0, a few levels
  under root port 0000:00:01.1.

  When that bridge runtime-suspends and is later asked to resume,
  pci_bridge_wait_for_secondary_bus() waits for the secondary bus to come back
  and it never does. The worker msleeps through the entire timeout and stays in
  D state for good. Runtime PM keeps queueing further resume requests — around
  three a second here — so blocked workers accumulate until the "pm" workqueue
  has none left.

  Nothing recovers from that, and it poisons shutdown. device_shutdown() calls
  the thunderbolt driver's handler, nhi_remove() waits on a PM completion that
  can never be serviced, and PID 1 blocks in D state — so reboot and poweroff
  both hang forever behind a frozen splash. Unplugging the display first does
  not help: the blocked workers never come back, so once a boot is poisoned it
  stays that way.

  Pinning every PCIe device on both USB4 paths to "on" keeps the bridges awake,
  so the resume that cannot finish is never attempted. It costs a little idle
  power and loses no functionality.

  This covers *runtime* PM only. A system suspend takes the whole hierarchy
  down regardless of these settings, so an S3 resume can still hit the same
  wait — untested as of writing.

  The two root ports are fixed devices on this board, so matching them by
  address is safe. Everything below them arrives through a tunnel and can be
  renumbered across boots and replugs, hence the DEVPATH prefix match instead
  of fixed addresses.

  Reproduces identically on 7.2.2 and 7.2.4. Drop this once the kernel stops
  doing it.
*/
{ ... }:
{
  flake.nixosModules.thunderboltRuntimePm =
    { ... }:
    {
      services.udev.extraRules = ''
        ACTION=="add|bind", SUBSYSTEM=="pci", KERNEL=="0000:00:01.1", ATTR{power/control}="on"
        ACTION=="add|bind", SUBSYSTEM=="pci", KERNEL=="0000:00:01.2", ATTR{power/control}="on"
        ACTION=="add|bind", SUBSYSTEM=="pci", DEVPATH=="*/0000:00:01.1/*", ATTR{power/control}="on"
        ACTION=="add|bind", SUBSYSTEM=="pci", DEVPATH=="*/0000:00:01.2/*", ATTR{power/control}="on"
      '';
    };
}
