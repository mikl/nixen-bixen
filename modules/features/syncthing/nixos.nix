/**
  Firewall holes for Syncthing. Separate from the home-manager module because
  the daemon runs per user but the ports are host-wide.
*/
{ ... }:
{
  flake.nixosModules.syncthing =
    { ... }:
    {
      networking.nftables.enable = true;
      networking.firewall = {
        enable = true;

        # 22000 carries sync traffic over both TCP and QUIC — Syncthing will
        # happily fall back to TCP, but only after the QUIC attempt times out.
        allowedTCPPorts = [ 22000 ];
        # 21027 is the local-discovery broadcast, without which peers on the
        # same LAN can only find each other via the global discovery servers.
        allowedUDPPorts = [
          21027
          22000
        ];
      };
    };
}
