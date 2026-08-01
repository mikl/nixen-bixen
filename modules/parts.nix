{
  inputs,
  lib,
  moduleLocation,
  ...
}:
{
  imports = [
    # adds home-manager options to flake-parts
    inputs.home-manager.flakeModules.home-manager
    # adds the darwinConfigurations option to flake-parts
    inputs.nix-darwin.flakeModules.default
  ];

  # flake-parts declares nixosModules and home-manager declares homeModules, but
  # nothing declares darwinModules, so define it the same way here. Without a
  # declared option the definitions in modules/ cannot be merged.
  options.flake.darwinModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
    apply = lib.mapAttrs (
      k: v: {
        _class = "darwin";
        _file = "${toString moduleLocation}#darwinModules.${k}";
        imports = [ v ];
      }
    );
    description = ''
      nix-darwin modules.

      For reusable pieces of configuration, service modules, etc.
    '';
  };

  config.systems = [
    "x86_64-linux"
    #"aarch64-linux"
    #"x86_64-darwin"
    "aarch64-darwin"
  ];
}
