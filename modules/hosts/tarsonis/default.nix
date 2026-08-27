/**
  Host “Tarsonis”, Framework Laptop 13, primary development machine.
*/
{ self, inputs, ... }:
{
  flake.nixosConfigurations.tarsonis = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.determinate.nixosModules.default
      self.nixosModules.tarsonisConfiguration
    ];
  };
}
