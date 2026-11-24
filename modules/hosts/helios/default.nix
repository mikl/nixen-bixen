/**
  Host “Helios”, HP ProDesk 400 G4 DM, headless devbox.
*/
{ self, inputs, ... }:
{
  flake.nixosConfigurations.helios = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.determinate.nixosModules.default
      self.nixosModules.heliosConfiguration
    ];
  };
}
