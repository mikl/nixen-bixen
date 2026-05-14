{ ... }:
{
  flake.homeModules.linuxDesktopSyncthing =
    { ... }:
    {
      services.syncthing = {
        enable = true;
        tray.enable = true;

        extraOptions = [
          # Remove once on 26.05.
          "--allow-newer-config"
        ];
      };
    };

  flake.nixosModules.linuxDesktopSyncthing =
    { ... }:
    {
      networking.nftables.enable = true;
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22000 ];
      };
    };
}
