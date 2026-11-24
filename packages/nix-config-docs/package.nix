{
  lib,
  self,
  stdenvNoCC,
  writeText,
  writers,
  # Build inputs
  mdbook,
  nixdoc,
}: let
  inherit (lib) maintainers;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.meta) getExe;
  inherit (lib.sources) cleanSource;
  inherit (lib.strings) join;
  inherit (writers) writeNu;

  src = cleanSource ../../docs;
  libSrc = ../../lib;

  repoRef =
    if self ? rev
    then "commit/${self.rev}"
    else "branch/main";

  repoRoot = "https://codeberg.org/bricked/nix-config/src/${repoRef}";

  patchConfig =
    # nu
    ''
      open ./book.toml
      | insert output.html.git-repository-url "${repoRoot}"
      | save --force ./book.toml
    '';

  patchLibDocs =
    # nu
    ''
      mkdir ./src/lib

      let names = ls ${libSrc} | each { get name | path basename }

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
      | str replace " <!-- library -->" $"\n($chapters)"
      | save --force ./src/SUMMARY.md
    '';

  patchPackagesDocs = let
    body =
      self.packages.x86_64-linux
      |> mapAttrsToList (name: package: let
        content = writeText "nix-config-docs-package-${name}" ''
          # `${package.pname or package.name}`

          ${package.meta.description or "No description"}${
            if package ? meta.mainProgram
            then ''

              ## Try it

              ```sh
              nix run git+https://codeberg.org/bricked/nix-config#${name}
              ```
            ''
            else ""
          }

          ## Source

          [`packages/${name}/package.nix`](${repoRoot}/packages/${name}/package.nix)
        '';
      in
        # nu
        ''

          install ${content} ./src/packages/${name}.md
          let chapters = $chapters | append "  - [`${name}`](./packages/${name}.md)"
        '')
      |> join "\n";
  in
    # nu
    ''
      mkdir ./src/packages
      let chapters = [];

      ${body}

      open --raw ./src/SUMMARY.md
      | str replace " <!-- packages -->" $"\n($chapters | str join "\n")"
      | save --force ./src/SUMMARY.md
    '';

  patchDocs = writeNu "nix-config-docs-patch" ''
    ${patchConfig}
    ${patchLibDocs}
    ${patchPackagesDocs}
  '';
in
  stdenvNoCC.mkDerivation {
    inherit src;
    name = "nix-config-docs";

    # Build
    buildInputs = [mdbook nixdoc];

    patchPhase = patchDocs;

    buildPhase = ''
      mdbook build

      mkdir --parents $out/share/doc

      cp --recursive ./book $out/share/doc/nix-config
    '';

    meta = {
      description = "Documentation for Bricked's Nix Configuration";
      maintainers = [maintainers.bricked];
    };
  }
