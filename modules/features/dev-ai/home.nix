/**
  AI coding agents feature.
*/
{ inputs, ... }:
{
  flake.homeModules.devAiHomeManager =
    { config, pkgs, ... }:
    let
      nixEnvironmentRule = ''
        # Environment

        Nix is available (flakes + the new CLI). A tool missing from PATH is
        never evidence the host lacks it.

        - One-off: `nix run nixpkgs#<pkg> -- <args>` (note the `--`).
        - Several tools, or an interactive session:
          `nix shell nixpkgs#<pkg1> nixpkgs#<pkg2> -c <cmd>`.

        Use this instead of skipping a check, or reporting a tool as
        unavailable. `python3` in particular is not on PATH — reach for
        `nix run` rather than working around it.

        Do not install packages persistently (`nix profile install`) or add
        them to a flake/home-manager config to satisfy a temporary need.
      '';

      unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    {

      home.file.".claude/rules/environment.md".text = nixEnvironmentRule;
      home.file.".grok/rules/environment.md".text = nixEnvironmentRule;

      home.packages = [
        unstable.claude-code
        unstable.grok-build
      ];
    };

}
