/**
  Host “Korhal”, M1 MacBook Pro, old development machine.
*/
{ self, inputs, ... }:
{
  flake.darwinConfigurations.korhal = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      self.darwinModules.korhalConfiguration
    ];
  };
}
