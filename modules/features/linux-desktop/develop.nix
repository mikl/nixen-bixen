/**
  Software development tools.
*/
{ ... }:
{
  flake.homeModules.linuxDesktopDevelop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # TODO: lagoon CLI
        _1password-cli
        claude-code
        ddev
        devenv
        docker-buildx
        docker-client
        docker-compose
        gh
        go-task
        httpie
        jetbrains.phpstorm
        jq
        just
        kamal
        mkcert
        nodejs_24 # General installation for use outside devenvs.
        nil # Language server for Nix.
        lazydocker
        upsun
        yq

        # Extra browsers for software development
        chromium
        librewolf
        vivaldi
      ];
    };
}
