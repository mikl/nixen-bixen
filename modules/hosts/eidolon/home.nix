/**
  Home manager config for Eidolon. Just there to select which features we want.
*/
{ self, inputs, ... }:
{
  flake.homeModules.eidolon =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.linuxDesktopBasis
        self.homeModules.linuxDesktopKDE
        self.homeModules.linuxDesktopSyncthing
      ];
    };
}
