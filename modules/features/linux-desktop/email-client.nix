/**
  Konfiguration for KDE desktop environment.
*/
{ ... }:
{
  flake.homeModules.linuxDesktopEmailClient =
    { lib, pkgs, ... }:
    {
      home.packages = with pkgs; [
        protonmail-bridge
        protonmail-bridge-gui
        protonmail-desktop
        thunderbird
      ];

      # Start Bridge in the tray only. Bridge's own "Open on startup" toggle
      # writes ProtonMailBridge.desktop with a pinned store path that breaks
      # after GC, so keep that toggle off and let this entry own autostart.
      xdg.configFile."autostart/proton-bridge-gui.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Proton Mail Bridge
        Exec=${lib.getExe' pkgs.protonmail-bridge-gui "protonmail-bridge-gui"} --no-window
        Icon=protonmail-bridge-gui
        Terminal=false
      '';
    };
}
