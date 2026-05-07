{ self, inputs, ... }:
{
  flake.nixosConfigurations.eidolon = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.eidolonConfiguration
    ];
  };
}
