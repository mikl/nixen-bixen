/**
  Home manager config for Eidolon. Just there to select which features we want.
*/
{ self, ... }:
{
  flake.homeModules.eidolon =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.linuxDesktopBasis
        self.homeModules.linuxDesktopKDE
        self.homeModules.linuxDesktopSyncthing
      ];
    };
}
