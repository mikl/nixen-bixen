{
  inputs,
  ...
}:
{
  imports = [
    # adds home-manager options to flake-parts
    inputs.home-manager.flakeModules.home-manager
    # adds the darwinConfigurations and darwinModules options to flake-parts
    inputs.nix-darwin.flakeModules.default
  ];

  systems = [
    "x86_64-linux"
    #"aarch64-linux"
    #"x86_64-darwin"
    "aarch64-darwin"
  ];
}
