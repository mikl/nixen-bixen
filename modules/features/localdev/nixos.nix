/**
  Local development config for NixOS
*/
{ ... }:
{
  flake.nixosModules.localdev =
    { ... }:
    {
      # Allow non-root users to pass settings to the Nix daemon (needed by devenv).
      nix.settings.trusted-users = [
        "root"
        "mikl"
      ];
    };
}
