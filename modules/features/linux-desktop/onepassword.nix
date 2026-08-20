/**
  1Password desktop app, plus its Firefox extension.

  The extension is installed through an enterprise policy rather than per
  profile. Every Firefox PWA gets its own profile, and the PWAsForFirefox
  runtime is built with MOZ_SYSTEM_POLICIES, so it reads the same
  /etc/firefox/policies/policies.json as regular Firefox — one policy covers
  every profile at once.
*/
{ ... }:
{
  flake.nixosModules.linuxDesktopOnePassword =
    { ... }:
    {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        # Certain features, including CLI integration and system authentication support,
        # require enabling PolKit integration on some desktop environments (e.g. Plasma).
        polkitPolicyOwners = [ "mikl" ];
      };

      # 1Password-BrowserSupport only talks to browsers it recognises by binary
      # name. Firefox and the PWA runtime are both called "firefox", which it
      # allows out of the box, so only the forks need listing here.
      environment.etc."1password/custom_allowed_browsers" = {
        text = ''
          librewolf
          vivaldi-bin
          .zen-beta-wrapped
          .zen-wrapped
          zen
          zen-beta
          zen-bin
        '';
        mode = "0755";
      };

      # Found in ~/.mozilla/native-messaging-hosts, which the PWA runtime
      # searches alongside MOZ_SYSTEM_DIR, so the extension reaches the
      # desktop app from inside a PWA without further setup.
      programs.firefox.policies.ExtensionSettings = {
        # 1Password – Password Manager
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
        };
      };
    };
}
