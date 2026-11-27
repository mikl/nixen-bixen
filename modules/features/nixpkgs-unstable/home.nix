/**
  Provides `unstable`, a nixpkgs-unstable package set, as a module argument.

  Each module that needs it imports this one. The explicit key makes the
  module system load it only once, so nixpkgs-unstable is evaluated once
  per home configuration instead of once per importing module.
*/
{ inputs, ... }:
{
  flake.homeModules.unstablePkgs =
    { pkgs, ... }:
    {
      key = "nixen-bixen#homeModules.unstablePkgs";

      _module.args.unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    };
}
