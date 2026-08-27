/**
  The parts of KDE that only work inside a Plasma session.

  Split out of kde.nix, which is otherwise standalone applications that run
  fine under Niri. Everything here plugs into KWin or the Plasma shell and has
  nowhere to load without them:

    - aurorae and oxygen ship `org.kde.kdecoration3` plugins — window
      decorations are KWin's job, and Niri draws its own.
    - oxygen also carries a `styles` plugin, but selecting a widget style is
      done in System Settings, which does not run here.
    - oxygen-sounds and ocean-sound-theme are freedesktop sound themes.
      Choosing one is a Plasma notification setting; Noctalia plays none.
    - plasma-thunderbolt is a KCM, so it needs the System Settings shell.
    - spectacle looks standalone but is not. `loadImagePlatform` only picks
      `ImagePlatformKWin` when the `org.kde.KWin.ScreenShot2` D-Bus service is
      registered, and it skips the X11 backend whenever XDG_SESSION_TYPE is
      wayland — so under Niri it falls through to `ImagePlatformNull` and
      captures nothing. Recording is no better: it binds the KWin-specific
      `zkde_screencast_unstable_v1` Wayland protocol, which Niri does not
      implement. niri/home.nix uses niri's own `screenshot` actions anyway.

  Loaded by eidolon, which still enables `services.desktopManager.plasma6`.
  Tarsonis is Niri-only and deliberately leaves this out.
*/
{ ... }:
{
  flake.homeModules.linuxDesktopPlasma =
    { pkgs, ... }:
    {
      home.packages = with pkgs.kdePackages; [
        aurorae
        ocean-sound-theme
        oxygen
        oxygen-icons
        oxygen-sounds
        plasma-thunderbolt
        spectacle
      ];
    };
}
