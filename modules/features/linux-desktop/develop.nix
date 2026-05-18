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
        docker-buildx
        docker-client
        docker-compose
        gh
        go-task
        httpie
        unstable.jetbrains.phpstorm
        jq
        just
        kamal
        mkcert
        nodejs_24 # General installation for use outside devenvs.
        nil # Language server for Nix.
        lazydocker
        upsun
        yq
        unstable.zed-editor

        # Extra browsers for software development
        chromium
        librewolf
        vivaldi
      ];
    };
}
