/**
  Host “Palaven”, home lab compact PC, mostly for experimentation.
*/
{ self, inputs, ... }:
{
  flake.nixosConfigurations.palaven = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.palavenConfiguration
    ];
  };
}
