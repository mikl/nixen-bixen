/**
  TEMPORARY: the pnpm deps hash for typescript-language-server 6.0.2 is stale
  in nixpkgs-weekly 7fd4004d (Oct 11); nixpkgs-unstable has since corrected
  it. Remove once nixpkgs-weekly catches up.
*/
{ ... }:
{
  flake.overlays.typescript-language-server = final: prev: {
    typescript-language-server = prev.typescript-language-server.overrideAttrs (old: {
      pnpmDeps = old.pnpmDeps.overrideAttrs {
        outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
      };
    });
  };
}
