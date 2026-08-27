/**
  Reuse the LUKS passphrase for the Plasma login and the KWallet unlock.

  systemd in the initrd stashes the passphrase it used to open the root device
  in the kernel keyring under the name “cryptsetup”. That keyring survives the
  switch-root, so with KeyringMode=inherit the login manager still sees it, and
  pam_systemd_loadkey can pull the passphrase out and put it in PAM_AUTHTOK
  during the autologin. pam_kwallet5 reads PAM_AUTHTOK in its auth phase and
  hands the key to kwalletd when the session opens.

  This only works when the LUKS passphrase, the user's login password and the
  KWallet password are all the same string. When they diverge, nothing breaks —
  KWallet simply prompts for its password as usual.

  Note the security trade-off: the machine boots straight into the desktop, so
  the LUKS passphrase becomes the only thing standing between a cold boot and a
  logged-in session. The screen locker still guards a running machine.

  Hosts using this need to pick the user themselves:

      services.displayManager.autoLogin = {
        enable = true;
        user = "someone";
      };

  This is also why the login manager cannot be swapped for a lighter one.
  greetd's autologin (`initial_session`) goes through
  `start_unauthenticated_session` with `authenticate: false`, so it never calls
  pam_authenticate at all — and it answers any PAM prompt with a null response.
  pam_systemd_loadkey and pam_kwallet5 are both auth-phase modules, so under
  greetd neither would run and the wallet would stay locked. Every other
  lightweight greeter (regreet, tuigreet, noctalia-greeter) is a greetd
  frontend and inherits the same behaviour. plasma-login-manager, by contrast,
  runs a real PAM auth stack for autologin — `plasmalogin-autologin`, patched
  below — and is an independent NixOS module, so it survives
  `services.desktopManager.plasma6` being turned off.

  Based on https://wiki.nixos.org/wiki/KDE#Unlock_KDE_Wallet_with_LUKS_password
*/
{ ... }:
{
  flake.nixosModules.luksAutoLogin =
    { config, ... }:
    {
      # Only systemd-cryptsetup puts the passphrase in the keyring; the
      # scripted initrd has nowhere to leave it.
      boot.initrd.systemd.enable = true;

      # Without this systemd gives the login manager a fresh session keyring
      # and the passphrase is invisible to it.
      systemd.services.plasmalogin.serviceConfig.KeyringMode = "inherit";

      # The stock autologin auth stack is just pam_nologin + pam_permit, so
      # nothing ever sets PAM_AUTHTOK and KWallet stays locked. Prepend the two
      # modules that fix that (auto-ordered rules start at 10000, so order 0 and
      # 100 put these first).
      #
      # Deliberately *not* `auth include plasmalogin` as the wiki suggests: that
      # pulls in the full login stack, where pam_fprintd sits at control
      # “sufficient” ahead of pam_kwallet5. With fprintd enabled that would
      # block every boot waiting for a finger swipe, and on success short
      # circuit the stack before pam_kwallet5 ever ran.
      security.pam.services.plasmalogin-autologin.rules.auth = {
        systemd_loadkey = {
          order = 0;
          control = "optional";
          modulePath = "${config.systemd.package}/lib/security/pam_systemd_loadkey.so";
        };
        kwallet = {
          order = 100;
          control = "optional";
          modulePath = "${config.security.pam.services.login.kwallet.package}/lib/security/pam_kwallet5.so";
        };
      };
    };
}
