{
  lib,
  self,
  stdenvNoCC,
  writers,
  # Build inputs
  mdbook,
  nixdoc,
}: let
  inherit (lib.meta) getExe;
  inherit (lib.sources) cleanSource;
  inherit (writers) writeNu;

  src = cleanSource ../../docs;
  libSrc = ../../lib;

  rev = self.rev or null;
  repoRoot = "https://codeberg.org/bricked/nix-config/src/${
    if rev != null
    then "commit/${rev}"
    else "branch/main"
  }";

  generateLibDocs =
    writeNu "nix-config-generate-lib-docs"
    # nu
    ''
      let names = ls ${libSrc} | each { get name | path basename }
      mkdir ./src/lib

      def "format entry" [] {
        $"## `($in.attrPath)` {#($in.attrPath)}

      ($in.description | str replace --all "\n#" "\n###")

      ### Source

      [`lib/($in.source.file):($in.source.line)`]\(${repoRoot}/lib/($in.source.file)#L($in.source.line))"
      }

      $names | par-each { |name|
        { version: 1, sources: [{ path: $"lib.($name)", file: $"($name)/lib.nix" }] }
        | to json | save ./($name).manifest.json

        let body = ${getExe nixdoc} --manifest ./($name).manifest.json --root ${libSrc}
        | from json
        | get entries
        | each { format entry }
        | str join "\n\n"

        $"# `lib.($name)` {#lib.($name)}

        ($body)"
        | save ./src/lib/($name).md

        rm ./($name).manifest.json
      }

      let chapters = $names
      | each { |name| $"  - [`lib.($name)`]\(./lib/($name).md)"}
      | str join "\n"

      open --raw ./src/SUMMARY.md
      | str replace " <!-- lib-chapters -->" $"\n($chapters)"
      | save --force ./src/SUMMARY.md
    '';
in
  stdenvNoCC.mkDerivation {
    inherit src;
    name = "nix-config-docs";

    # Build
    buildInputs = [mdbook nixdoc];

    patchPhase = ''
      ${generateLibDocs}
    '';

    buildPhase = ''
      mdbook build

      cp --recursive ./book $out
    '';
  }
