/**
  Syncthing as a plain user service, with no desktop integration.

  Deliberately unconfigured beyond enabling it: devices and folders are set up
  through the web UI on localhost:8384 and live in ~/.config/syncthing, the
  same arrangement korhal uses, so the pre-Nix configuration survives.

  linux-desktop/syncthing.nix builds on this and adds the tray icon; hosts
  without a graphical session import this one directly. Note that as a *user*
  service it only runs while the user manager is up, which on a headless host
  means the account needs `users.users.<name>.linger = true`.
*/
{ ... }:
{
  flake.homeModules.syncthingHomeManager =
    { ... }:
    {
      services.syncthing.enable = true;
    };
}
