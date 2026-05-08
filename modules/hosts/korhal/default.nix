/**
  Host “Korhal”, M1 MacBook Pro, old development machine.
*/
{ self, inputs, ... }:
{
  flake.homeConfigurations.korhal = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
    modules = [
      self.homeModules.korhalHomeManager
    ];
  };
}
