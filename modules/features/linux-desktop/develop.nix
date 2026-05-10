/**
  Software development tools.
*/
{ self, inputs, ... }:
{
  flake.homeModules.linuxDesktopDevelop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # TODO: upsun and lagoon CLIs
        ddev
        docker-buildx
        docker-client
        docker-compose
        gh
        go-task
        httpie
        jetbrains.phpstorm
        just
        kamal
        mise
        lazydocker
      ];
    };
}
