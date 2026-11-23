{
  lib,
  mdbook,
  nixdoc,
  stdenvNoCC,
}: let
  inherit (lib.sources) cleanSource;
in
  stdenvNoCC.mkDerivation {
    name = "nix-config-docs";
    src = cleanSource ../../docs;

    # Build
    buildInputs = [mdbook nixdoc];

    patchPhase = ''
      mkdir --parents ./src/lib
      nixdoc --file ${../../lib/imports/lib.nix} --category options --description "Import Functions" > ./src/lib/imports.md
      nixdoc --file ${../../lib/modules/lib.nix} --category options --description "Module Functions" > ./src/lib/modules.md
      nixdoc --file ${../../lib/options/lib.nix} --category options --description "Option Functions" > ./src/lib/options.md
      nixdoc --file ${../../lib/trivial/lib.nix} --category options --description "Miscallaneous Functions" > ./src/lib/trivial.md
      nixdoc --file ${../../lib/resolvers/lib.nix} --category options --description "Resolver Functions" > ./src/lib/resolvers.md
    '';

    buildPhase = ''
      mdbook build

      cp --recursive book $out
    '';
  }
