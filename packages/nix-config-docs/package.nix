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
      nixdoc --file ${../../lib/imports/lib.nix} --category imports --description "Import Functions" > ./src/lib/imports.md
      nixdoc --file ${../../lib/modules/lib.nix} --category modules --description "Module Functions" > ./src/lib/modules.md
      nixdoc --file ${../../lib/options/lib.nix} --category options --description "Option Functions" > ./src/lib/options.md
      nixdoc --file ${../../lib/trivial/lib.nix} --category trivial --description "Miscallaneous Functions" > ./src/lib/trivial.md
      nixdoc --file ${../../lib/resolvers/lib.nix} --category resolvers --description "Resolver Functions" > ./src/lib/resolvers.md
    '';

    buildPhase = ''
      mdbook build

      cp --recursive book $out
    '';
  }
