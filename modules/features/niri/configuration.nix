/**
  Niri (scrollable-tiling Wayland compositor) as a session alongside Plasma.

  Plasma stays installed and selectable at the login screen; this module only
  adds a second session and rewires the bits of it that nixpkgs' `programs.niri`
  points at GNOME by default, so that KDE Wallet — rather than gnome-keyring —
  keeps being the secret store.
*/
{ ... }:
{
  flake.nixosModules.niriConfiguration =
    { pkgs, lib, ... }:
    {
      programs.niri = {
        enable = true;

        # Nautilus is only pulled in to back the GNOME file-chooser portal.
        # We point FileChooser at the KDE backend below instead.
        useNautilus = false;
      };

      # `programs.niri` turns gnome-keyring on by default. Two Secret Service
      # providers racing for org.freedesktop.secrets is exactly how you end up
      # with secrets split across two stores, so KWallet gets it alone. Noctalia
      # v5 is itself a libsecret client — its saved credentials and encrypted
      # state (clipboard history, calendar cache) land in the same wallet.
      services.gnome.gnome-keyring.enable = false;

      xdg.portal = {
        extraPortals = with pkgs.kdePackages; [
          # ksecretd, shipped in kwallet, backs org.freedesktop.impl.portal.Secret.
          kwallet
          xdg-desktop-portal-kde
        ];

        # `default` deliberately stays at the module's ["gnome" "gtk"]:
        # xdg-desktop-portal-gnome is the only backend that can screencast
        # under niri (niri implements Mutter's ScreenCast D-Bus API for it),
        # and xdg-desktop-portal-kde's equivalent talks to KWin.
        config.niri = {
          "org.freedesktop.impl.portal.Secret" = lib.mkForce "kwallet";
          "org.freedesktop.impl.portal.FileChooser" = lib.mkForce "kde";
        };
      };

      # Since KDE Frameworks 6.28 the wallet daemon is `ksecretd`, which serves
      # org.freedesktop.secrets directly; `kwalletd6` is now just a shim
      # speaking the legacy org.kde.KWallet API on top of it. Either way it is
      # pam_kwallet5 that starts it with the login password, so the wallet is
      # already open when the session comes up.
      #
      # This also has to stay the `login` service specifically: Noctalia's lock
      # screen calls pam_authenticate against a hard-coded "login" service, so
      # /etc/pam.d/login is the one stack that must work for both.
      #
      # The plasma6 module sets this too; declaring it here keeps the Niri
      # session working if Plasma is ever removed.
      security.pam.services.login.kwallet.enable = lib.mkDefault true;

      # kwallet-pam ships `plasma-kwallet-pam.service`, but the unit never
      # reaches the systemd search path: Plasma instead runs its XDG autostart
      # entry directly, and that entry carries `X-systemd-skip=true` so
      # systemd's autostart generator ignores it as well. So spell it out.
      #
      # pam_kwallet5 leaves a socket behind at login and ksecretd sits reading
      # it; pam_kwallet_init pipes the session environment (DBUS_SESSION_BUS_
      # ADDRESS above all) into that socket. Without this step ksecretd never
      # reaches the session bus and the wallet stays locked. `niri-session`
      # runs a bare `systemctl --user import-environment`, so PAM_KWALLET5_LOGIN
      # is present in the user manager by the time this runs.
      systemd.user.services.kwallet-pam-unlock = {
        description = "Hand the session environment to ksecretd for KWallet auto-unlock";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        # Plasma sessions do this themselves; running it twice would just make
        # socat fail against an already-consumed socket.
        unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init";
          Slice = "background.slice";
        };
      };

      # Breeze and the KDE platform theme for Qt apps outside Plasma, so
      # Dolphin/Kate/Okular look the way they do in the Plasma session.
      # Deliberately no `qt.style`: that sets QT_STYLE_OVERRIDE system-wide,
      # which would also override whatever widget style System Settings has
      # been told to use in the Plasma session. plasma-integration picks the
      # style up from kdeglobals on its own.
      qt = {
        enable = true;
        platformTheme = "kde";
      };

      environment.systemPackages = with pkgs; [
        kdePackages.kwallet
        kdePackages.kwalletmanager # KWallet GUI + KCM, useful without systemsettings
        xwayland-satellite # niri spawns this on demand for X11 clients
      ];

      # Noctalia v5 drives external-monitor brightness over DDC/CI via ddcutil,
      # which needs /dev/i2c-*. This module loads i2c-dev and ships udev rules
      # granting access to locally seated users, so no group juggling is needed.
      hardware.i2c.enable = true;

      # Both Plasma and Niri wants to set this. Force it to Niri.
      services.displayManager.defaultSession = "niri";
    };
}
