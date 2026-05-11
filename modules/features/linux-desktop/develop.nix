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
        lazydocker
        upsun
        yq
      ];

      programs.mise = {
        enable = true;
        enableFishIntegration = true;
        globalConfig = {
          settings.idiomatic_version_file_enable_tools = [
            "node"
            "ruby"
          ];
        };
      };
    };
}
