{
  description = "Nix setup by Mikkel T. Hoegh";

  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      import-tree.url = "github:vic/import-tree";
      flake-parts.url = "github:hercules-ci/flake-parts";
    };

    outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
