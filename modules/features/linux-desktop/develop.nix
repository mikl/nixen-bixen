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
        unstable.claude-code
        ddev
        devenv
        dive
        docker-buildx
        docker-client
        docker-compose
        gh
        unstable.jetbrains.phpstorm
        mkcert
        nodejs_24 # General installation for use outside devenvs.
        nil # Language server for Nix.
        lazydocker
        upsun
        unstable.zed-editor

        # Extra browsers for software development
        chromium
        librewolf
        vivaldi
      ];
    };
}
