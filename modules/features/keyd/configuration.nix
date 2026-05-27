/**
  System-wide configuration for keyd.

  Based on https://wiki.nixos.org/wiki/Keyd
*/
{ ... }:
{
  flake.nixosModules.keydConfiguration =
    { config, pkgs, ... }:
    {
      services.keyd = {
        enable = true;
        keyboards = {
          default = {
            # Rules for all keyboards.
            ids = [ "*" ];
            settings = {
              meta = {
                # Universal copy-paste keys using MacOS-like shortcuts.
                c = "C-insert";
                v = "S-insert";
                x = "S-delete";
              };
            };
          };
          framework = {
            # Special bindings for the Framework laptop built-in keyboard.
            ids = [
              "0001:0001:70533846"
              "0001:0001:09b4e68d"
            ];

            settings = {
              main = {
                # Swap left Meta key with left Alt key.
                leftmeta = "leftalt";
                leftalt = "leftmeta";
              };

              meta = {
                # Universal copy-paste keys using MacOS-like shortcuts.
                c = "C-insert";
                v = "S-insert";
                x = "S-delete";
              };
            };
          };
        };
      };
    };
}
