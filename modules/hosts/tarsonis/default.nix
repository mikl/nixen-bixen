/**
  Host “Tarsonis”, Framework Laptop 13, primary development machine.

  Not yet on NixOS, just using Home Manager for now.
*/
{ self, inputs, ... }:
{
  flake.homeConfigurations.tarsonis = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = [
      self.homeModules.tarsonisHomeManager
    ];
  };
}
