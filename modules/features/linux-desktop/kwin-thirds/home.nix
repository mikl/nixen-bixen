/**
  KWin script: quick-tile to 1/3 or 2/3 of the screen.

  Native “Quick Tile to the Left/Right” is hard-coded to half the work area.
  This adds the same full-height snap at one third and two thirds. Shortcuts
  show up under KWin in System Settings and can be rebound there.

  Defaults sit next to the existing half-tile binds (Meta+Ctrl+Left/Right):
    Meta+Left / Meta+Right                 — two thirds
    Meta+Ctrl+Shift+Left / Right           — one third
*/
{ ... }:
{
  flake.homeModules.linuxDesktopKwinThirds =
    { lib, pkgs, ... }:
    {
      xdg.dataFile."kwin/scripts/thirds".source = ./script;

      # kwinrc is a live KDE file; write only the plugin flag rather than
      # replacing the whole thing.
      home.activation.enableKwinThirds = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6"} --file kwinrc --group Plugins --key thirdsEnabled true
        run ${pkgs.dbus}/bin/dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure || true
      '';
    };
}
