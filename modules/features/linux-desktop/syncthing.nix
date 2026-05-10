{ self, inputs, ... }:
{
  flake.homeModules.linuxDesktopSyncthing =
    { pkgs, ... }:
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
}
