/**
  Software development tools.
*/
{ inputs, ... }:
{
  flake.homeModules.linuxDesktopDevelop =
    { pkgs, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    {
      home.packages = with pkgs; [
        # TODO: lagoon CLI
        _1password-cli
        dive
        docker-buildx
        docker-client
        docker-compose
        unstable.jetbrains.phpstorm
        unstable.zed-editor

        # Extra browsers for software development
        chromium
        # librewolf # nixpkg currently unmaintained

        # Same story as Signal in linuxDesktopBasis: left to `detect`, Chromium
        # reads XDG_CURRENT_DESKTOP to choose a secret-storage backend. Under
        # Plasma that resolved to KWallet, and Vivaldi — which does not rebrand
        # the folder, so it is Chrome’s name in the wallet — put its key in
        # “Chrome Keys/Chrome Safe Storage” and encrypted saved logins and
        # cookies with it. Niri is an unknown desktop, `detect` stops resolving
        # to KWallet, and Chromium’s newer org.freedesktop.portal.Secret key
        # provider takes over with a different key. The old key is still in the
        # wallet, so nothing is lost, but Vivaldi cannot read its own profile
        # and refuses to start with “Decryption Failed: Risk of Data Loss”.
        # Naming the backend keeps Plasma and Niri sessions on the same key.
        (vivaldi.override { commandLineArgs = "--password-store=kwallet6"; })
      ];
    };
}
