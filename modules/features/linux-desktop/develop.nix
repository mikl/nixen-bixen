/**
  Software development tools.
*/
{ self, inputs, ... }:
{
  flake.homeModules.linuxDesktopDevelop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # TODO: lagoon CLI
        _1password-cli
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
        nil # Language server for Nix.
        lazydocker
        upsun
        yq
      ];
    };
}
