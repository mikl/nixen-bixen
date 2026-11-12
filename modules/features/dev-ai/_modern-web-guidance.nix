/**
  Modern Web Guidance skill (https://github.com/GoogleChrome/modern-web-guidance),
  packaged to run offline.

  The CLI that the skill calls ships only in the npm tarball, not in the
  GitHub repo. It bundles its own search index, so it needs no network
  apart from telemetry, which the wrapper turns off. SKILL.md is patched to
  call the wrapped binary instead of `npx …@latest`.

  To update, bump `version` and the hash; SKILL.md and the CLI come from
  the same tarball, so the skill-version check stays in step.

  The leading underscore keeps import-tree from loading this file as a
  module; dev-ai/home.nix calls it with callPackage.
*/
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "modern-web-guidance";
  version = "1.0.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/modern-web-guidance/-/modern-web-guidance-${finalAttrs.version}.tgz";
    hash = "sha256-vXqmI60QcQqa1meP28wLiQyQPFT9ar/BJv9C3gHw5Xc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    skill=$out/share/modern-web-guidance/skill
    mkdir -p $out/bin $(dirname $skill)
    cp -r skills/modern-web-guidance $skill

    makeWrapper ${lib.getExe nodejs} $out/bin/modern-web-guidance \
      --add-flags $skill/modern-web.mjs \
      --set DISABLE_TELEMETRY 1

    # Drop the npx/pnpx section (runner, network and offline advice), which
    # does not apply to a locally installed CLI.
    sed -i '/^## Using npx \/ pnpx/,/^## Guidelines/{/^## Guidelines/!d}' $skill/SKILL.md
    substituteInPlace $skill/SKILL.md \
      --replace-fail 'Run `modern-web-guidance` directly with `npx` using' \
                     'Run `modern-web-guidance` (installed locally, works offline) using' \
      --replace-fail 'npx -y modern-web-guidance@latest' 'modern-web-guidance'

    # Fail loudly if a new upstream SKILL.md still points at npx.
    if grep -n 'npx\|pnpx' $skill/SKILL.md; then
      echo "SKILL.md still mentions npx; update the patching above" >&2
      exit 1
    fi

    runHook postInstall
  '';

  meta = {
    description = "Modern web platform guidance skill for coding agents";
    homepage = "https://github.com/GoogleChrome/modern-web-guidance";
    license = lib.licenses.asl20;
    mainProgram = "modern-web-guidance";
  };
})
