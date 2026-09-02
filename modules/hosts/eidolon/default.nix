/**
  Host “Eidolon”, home lab compact PC. Headless: no desktop session, reached
  over SSH and Tailscale.
*/
{ self, inputs, ... }:
{
  flake.nixosConfigurations.eidolon = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.determinate.nixosModules.default
      self.nixosModules.eidolonConfiguration
    ];
  };
}
