/**
  Home manager config for Tarsonis. Just there to select which features we want.
*/
{ self, ... }:
{
  flake.homeModules.tarsonis =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.linuxDesktopBasis
        self.homeModules.linuxDesktopDevelop
        self.homeModules.linuxDesktopKDE
        self.homeModules.linuxDesktopSyncthing
      ];
    };
}
