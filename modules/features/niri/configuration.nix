/**
  Niri (scrollable-tiling Wayland compositor) as the graphical session.

  This module stands on its own. It rewires the bits of nixpkgs'
  `programs.niri` that point at GNOME by default, so that KDE Wallet — rather
  than gnome-keyring — is the secret store, and it declares the desktop
  plumbing that a bare compositor does not bring along but that
  `services.desktopManager.plasma6` used to supply as a side effect.

  Tarsonis has no Plasma desktop any more; eidolon still enables plasma6
  alongside Niri. Everything here is therefore either a list append or
  `mkDefault`, so where the two modules set the same option Plasma's own
  definition keeps winning on eidolon.

  The login manager is a separate concern:
  `services.displayManager.plasma-login-manager` is an independent module and
  stays enabled on both hosts. See modules/features/luks-auto-login for why it
  cannot be swapped for greetd.
*/
{ ... }:
{
  flake.nixosModules.niriConfiguration =
    {
      config,
      lib,
      pkgs,
      ...
    }:
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
        kdePackages.breeze # breeze_cursors, the theme niri/home.nix asks for
        kdePackages.kwallet
        # Standalone wallet GUI, plus a KCM that the systemsettings shell can host
        # — `qt.platformTheme = "kde"` above makes nixpkgs' qt module install it.
        kdePackages.kwalletmanager
        xwayland-satellite # niri spawns this on demand for X11 clients
      ];

      # Noctalia v5 drives external-monitor brightness over DDC/CI via ddcutil,
      # which needs /dev/i2c-*. This module loads i2c-dev and ships udev rules
      # granting access to locally seated users, so no group juggling is needed.
      hardware.i2c.enable = true;

      # The three D-Bus services Noctalia's bar talks to: src/dbus/upower for
      # the battery widget, src/dbus/power/power_profiles_service.cpp for the
      # power-profile widget, src/dbus/accounts for the user name and avatar.
      # Nothing in `programs.niri` pulls these in — plasma6 did.
      services.accounts-daemon.enable = lib.mkDefault true;
      services.power-profiles-daemon.enable = lib.mkDefault true;
      services.upower.enable = lib.mkDefault true;

      # Removable media in Dolphin, and the userspace mounts behind it.
      services.udisks2.enable = lib.mkDefault true;
      programs.fuse.enable = lib.mkDefault true;

      # speech-dispatcher exists here only to give Orca a voice, and Orca is
      # gone. `services.graphical-desktop` turns it on at `mkDefault true`, so a
      # plain definition is enough to override it.
      #
      # Guarded on orca rather than on plasma6: `services.orca` itself sets
      # `services.speechd.enable = true` with a plain (equal-priority)
      # definition, so an unconditional `false` here would be a conflict on
      # eidolon, where plasma6 still enables Orca. mkIf drops this definition
      # entirely in that case and lets Orca's own win.
      services.speechd.enable = lib.mkIf (!config.services.orca.enable) false;

      # GTK apps need the SVG loader to render scalable icons; without it the
      # hicolor/scalable trees that basis.nix goes out of its way to index are
      # unreadable.
      programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

      # Graphical passphrase prompt for ssh-add and git over SSH. Same value
      # plasma6 sets, so the two mkDefaults merge cleanly on eidolon.
      programs.ssh.askPassword = lib.mkDefault "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";

      # niri's `programs.niri` already defaults this to "niri"; on eidolon
      # plasma6 also sets it (to "plasma") at the same priority, so the choice
      # has to be forced rather than defaulted.
      services.displayManager.defaultSession = lib.mkForce "niri";
    };
}
