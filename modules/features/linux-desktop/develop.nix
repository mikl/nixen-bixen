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
        inkscape
        unstable.jetbrains.phpstorm
        sourcegit
        svgo
        unstable.zed-editor

        # Zed’s Delta. Proprietary, packaged in its own flake.
        inputs.zed-delta.packages.${pkgs.stdenv.hostPlatform.system}.delta

        # Extra browsers for software development
        chromium
        # librewolf # nixpkg currently unmaintained
        vivaldi
      ];
    };
}
