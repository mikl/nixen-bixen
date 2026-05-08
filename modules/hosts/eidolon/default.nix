/**
  Host “Eidolon”, home lab compact PC, mostly for experimentation.
*/
{ self, inputs, ... }:
{
  flake.nixosConfigurations.eidolon = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.eidolonConfiguration
    ];
  };
}
