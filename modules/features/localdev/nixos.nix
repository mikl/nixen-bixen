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
      # Let Docker containers reach dev servers running on the host.
      networking.firewall.extraInputRules = ''
        ip saddr 172.16.0.0/12 tcp dport 3000 accept comment "docker -> host dev servers"
      '';
    };
}
