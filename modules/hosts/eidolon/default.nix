/**
  Host “Eidolon”, home lab compact PC, mostly for experimentation.
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
