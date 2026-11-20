{
  lib,
  mdbook,
  stdenvNoCC,
}: let
  inherit (lib.sources) cleanSource;
in
  stdenvNoCC.mkDerivation {
    name = "nix-config-docs";
    src = cleanSource ../../docs;

    # Build
    buildInputs = [mdbook];

    buildPhase = ''
      mdbook build

      cp --recursive book $out
    '';
  }
