/**
  Syncthing plus its tray icon, for hosts with a graphical session.

  The service itself is syncthing/home.nix; all this adds is the tray, which
  needs a status-notifier host to dock into and so has nowhere to go on a
  headless machine.
*/
{ self, ... }:
{
  flake.homeModules.linuxDesktopSyncthing =
    { ... }:
    {
      imports = [
        self.homeModules.syncthingHomeManager
      ];

      services.syncthing.tray.enable = true;
    };
}
