/**
  Run Android apps in a Waydroid container, each in its own Wayland window.

  The NixOS module covers the system side: binder, the LXC container service,
  and trusting waydroid0 in the firewall. The Android image itself is
  downloaded imperatively, once, into /var/lib/waydroid:

    sudo waydroid init            # plain LineageOS
    sudo waydroid init -s GAPPS   # with the Play Store

  A GAPPS image also has to be registered with Google before the Play Store
  will sign in, and ARM-only apps need a translation layer (libndk or
  libhoudini) installed into the image; the community waydroid_script handles
  both.
*/
{ ... }:
{
  flake.nixosModules.waydroid =
    { config, lib, ... }:
    {
      virtualisation.waydroid.enable = true;

      # Docker sets the FORWARD policy to DROP when it turns on IP forwarding,
      # which also drops the container's traffic from waydroid0 out to the
      # world: Android boots fine but has no network. Docker's own networks
      # get explicit accept rules regardless, so this only stops it from
      # shutting out everyone else.
      virtualisation.docker.daemon.settings = lib.mkIf config.virtualisation.docker.enable {
        ip-forward-no-drop = true;
      };
    };
}
