{ inputs, ... }:
{
  flake.nixosModules.satisfactoryServer =
    { pkgs, ... }:
    {
      imports = [
        inputs.satisfactory-server.nixosModules.default
      ];

      services.satisfactory = {
        enable = true;
        openFirewall = true;
        stateDir = "/var/lib/satisfactory";
      };
    };
}
