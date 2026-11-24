{
  inputs,
  lib,
  pkgs,
  self,
  stdenvNoCC,
  writeText,
  writers,
  # Build inputs
  mdbook,
  nixdoc,
}: let
  inherit (builtins) concatStringsSep mapAttrs;
  inherit (lib) maintainers;
  inherit (lib.attrsets) mapAttrsToList zipAttrs;
  inherit (lib.lists) flatten optional singleton;
  inherit (lib.meta) getExe;
  inherit (lib.options) isOption renderOptionValue showOption;
  inherit (lib.sources) cleanSource;
  inherit (lib.strings) join;
  inherit (writers) writeNu;

  src = cleanSource self.tree.doc;

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

  patchLibDoc =
    # nu
    ''
      mkdir ./src/lib

      let names = ls ${self.tree.lib} | each { get name | path basename }

      def "format entry" [] {
        $"## `($in.attrPath)` {#($in.attrPath)}

      ($in.description | str replace --all "\n#" "\n###")

      ### Source {#($in.attrPath)-source}

      [`lib/($in.source.file):($in.source.line)`]\(${repoRoot}/lib/($in.source.file)#L($in.source.line))"
      }

      $names | par-each { |name|
        { version: 1, sources: [{ path: $"lib.($name)", file: $"($name)/lib.nix" }] }
        | to json | save ./($name).manifest.json

        let body = ${getExe nixdoc} --manifest ./($name).manifest.json --root ${self.tree.lib}
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

  patchPackagesDoc = let
    body =
      self.packages.x86_64-linux
      |> mapAttrsToList (name: package: let
        sections =
          singleton "# `${package.pname or package.name}`"
          ++ singleton "${package.meta.description or "No description"}."
          ++ optional (package ? meta.longDescription) package.meta.longDescription
          ++ optional (package ? meta.mainProgram) ''
            ## Run it

            ```sh
            nix run git+https://codeberg.org/bricked/nix-config#${name}
            ```
          ''
          ++ singleton ''
            ## Source

            [`packages/${name}/package.nix`](${repoRoot}/packages/${name}/package.nix)
          '';

        content = concatStringsSep "\n\n" sections |> writeText "nix-config-doc-package-${name}";
      in
        # nu
        ''
          cp ${content} ./src/packages/${name}.md
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

  renderOptions = class: attr: option: let
    attrText = showOption attr;
    defaultText = (renderOptionValue option.defaultText or option.default).text;
    exampleText = (renderOptionValue option.example).text;
    content = concatStringsSep "\n\n" sections;

    sections =
      singleton "### `${attrText}` {#${class}-option-${attrText}}"
      ++ singleton option.description
      ++ singleton ''
        ### Type {#${class}-option-${attrText}-type}

        ${option.type.description}
      ''
      ++ optional (option ? defaultText || option ? default) ''
        ### Default {#${class}-option-${attrText}-default}

        ```nix
        ${defaultText}
        ```
      ''
      ++ optional (option ? example) ''
        ### Example {#${class}-option-${attrText}-example}

        ```nix
        ${exampleText}
        ```
      '';

    children =
      option
      |> mapAttrsToList (name: option: renderOptions class (attr ++ [name]) option)
      |> flatten;
  in
    if isOption option
    then singleton content
    else children;

  specialArgs = {
    inherit inputs lib self pkgs;
    config = null;
  };

  renderModule = title: class: name: path: let
    module = import path specialArgs;
    optionSections = renderOptions class [] (module.options or {});
    body =
      if optionSections == []
      then "No options."
      else concatStringsSep "\n\n" optionSections;
  in ''
    ## ${title} {#${class}}

    ${body}

    ## Source {#${class}-source}

    [`modules/${name}/${class}.nix`](${repoRoot}/modules/${name}/${class}.nix)
  '';

  patchModulesDoc = let
    commonOptions = self.tree.commonModules |> mapAttrs (renderModule "Common module" "common");
    nixosOptions = self.tree.nixosModules |> mapAttrs (renderModule "NixOS module" "nixos");
    homeOptions = self.tree.homeModules |> mapAttrs (renderModule "Home Manager module" "home");

    options = zipAttrs [commonOptions nixosOptions homeOptions];

    body =
      options
      |> mapAttrsToList (
        name: sections: let
          content =
            ''
              # `${name}`

              ${sections |> concatStringsSep "\n\n"}
            ''
            |> writeText "nix-config-doc-module-${name}";
        in
          # nu
          ''
            cp ${content} ./src/modules/${name}.md
            let chapters = $chapters | append "  - [`${name}`](./modules/${name}.md)"
          ''
      )
      |> concatStringsSep "\n";
  in
    # nu
    ''
      mkdir ./src/modules
      let chapters = [];

      ${body}

      open --raw ./src/SUMMARY.md
      | str replace " <!-- modules -->" $"\n($chapters | str join "\n")"
      | save --force ./src/SUMMARY.md
    '';

  patchDoc = writeNu "nix-config-doc-patch" ''
    ${patchConfig}
    ${patchLibDoc}
    ${patchPackagesDoc}
    ${patchModulesDoc}
  '';
in
  stdenvNoCC.mkDerivation {
    inherit src;
    name = "nix-config-doc";

    # Build
    buildInputs = [mdbook nixdoc];

    patchPhase = patchDoc;

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
