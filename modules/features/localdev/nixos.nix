/**
  Local development config for NixOS
*/
{ ... }:
{
  flake.nixosModules.localdev =
    { ... }:
    {

      networking.hosts = {
        "127.0.0.1" = ["dpl-cms.local"];
      };

      # Allow non-root users to pass settings to the Nix daemon (needed by devenv).
      nix.settings.trusted-users = [ "root" "mikl" ];
  };
}
