/**
  Caddy web server, configured from outside the Nix store.

  The Caddyfile lives at /srv/caddy/Caddyfile and is edited by hand, so
  reverse proxies and vhosts can be added without a rebuild. /srv is the FHS
  slot for service-specific data and nothing else in this flake manages it.

  services.caddy.configFile is typed as a path, but a *string* path is not
  copied into the store — a bare path literal would be, which is exactly what
  we are avoiding here. The module symlinks it to /etc/caddy/caddy_config and
  runs caddy against that.

  Two things follow from the file being outside the store. Its content is not
  seen at evaluation time, so a syntax error only surfaces when caddy starts —
  run `caddy validate --adapter caddyfile --config /srv/caddy/Caddyfile`
  before applying one. And the unit's reloadTriggers now hold a constant
  string, so nixos-rebuild has no way to notice an edit: reload by hand with
  `systemctl reload caddy`, which validates first and leaves the running
  config alone if the new one is broken.
*/
{ ... }:
{
  flake.nixosModules.caddyServer =
    { ... }:
    let
      configDir = "/srv/caddy";
      configFile = "${configDir}/Caddyfile";
    in
    {
      services.caddy = {
        enable = true;
        inherit configFile;

        # openFirewall is deliberately left off. It opens services.caddy
        # httpPort/httpsPort, and those options only reach caddy through the
        # module-generated Caddyfile — which our own configFile replaces. On
        # this host they would be firewall-only knobs that no longer say
        # anything about what caddy binds, so the ports are spelled out below
        # instead.
      };

      # Matches the ports the hand-written Caddyfile is expected to listen on;
      # keep the two in sync by hand. UDP/443 is for HTTP/3, which caddy turns
      # on by default for TLS sites and which openFirewall would not cover.
      networking.firewall = {
        allowedTCPPorts = [
          80
          443
        ];
        allowedUDPPorts = [ 443 ];
      };

      systemd.tmpfiles.rules = [
        "d ${configDir} 0755 root root -"
        # Seed a placeholder so caddy.service comes up on a machine that has
        # never had a Caddyfile written. tmpfiles only writes it when the file
        # is absent, so a real config is never clobbered.
        ''f ${configFile} 0644 root root - :80 {\n\trespond "eidolon: placeholder Caddyfile"\n}\n''
      ];
    };
}
