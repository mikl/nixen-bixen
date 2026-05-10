/**
  Home manager config for Tarsonis. Just there to select which features we want.
*/
{ self, inputs, ... }:
{
  flake.homeModules.tarsonis =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.linuxDesktopBasis
        self.homeModules.linuxDesktopKDE
        self.homeModules.linuxDesktopSyncthing
      ];
    };
}
