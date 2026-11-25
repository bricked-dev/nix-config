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
  inherit (lib.strings) escape join;
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
      let names = ls ${self.tree.lib} | each { get name | path basename }

      def "format entry" [] {
        let attrPath = $in.attrPath
        let attrList = $attrPath | split row "."
        let attrHead = $attrList | last;
        let attrTail = $attrList | drop 1 | str join ".";

        let description = $in.description
        | str replace --all --regex --multiline '^(#)+\s*(.+)$' { |prefix, title|
          let title_slug = $title | str lowercase | str kebab-case
          let id = $"attribute-($title_slug)-($attrPath)"
          $"##($prefix) ($title) {#($id)}"
        }

      $"## `($attrPath)` {#attribute-($attrPath)}

      ($description)

      ### Usage {#attribute-usage-($attrPath)}

      ```nix
      let
        inherit \(inputs.nix-config.lib.($attrTail)) ($attrHead);
      in # ...
      ```

      ### Source {#attribute-source-($attrPath)}

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

      let summary = $names
      | each { $"  - [`($in)`]\(./lib/($in).md)" }
      | str join "\n"

      let list = $names
      | each { $"- [`($in)`]\(./($in).md)" }
      | str join "\n"

      open --raw ./src/SUMMARY.md
      | str replace " <!-- lib-summary -->" $"\n($summary)"
      | save --force ./src/SUMMARY.md

      open --raw ./src/lib/README.md
      | str replace "<!-- lib-list -->" $list
      | save --force ./src/lib/README.md
    '';

  patchPackagesDoc = let
    body =
      self.packages.x86_64-linux
      |> mapAttrsToList (name: package: let
        sections =
          singleton "# `${package.pname or package.name}`"
          ++ singleton "${package.meta.longDescription or package.meta.description or "No description"}."
          ++ optional (package ? meta.mainProgram) ''
            ## Usage

            ### Nix command

            ```sh
            nix run git+https://codeberg.org/bricked/nix-config#${name}
            ```

            ### NixOS

            ```nix
            { inputs, pkgs, ... }: let
              inherit (pkgs.stdenv.hostPlatform) system;
              nixConfigPkgs = inputs.nix-config.packages.''${system};
            in {
              environment.systemPackages = [ nixConfigPkgs.${name} ]
            }
            ```

            ### Home Manager

            ```nix
            { inputs, pkgs, ... }: let
              inherit (pkgs.stdenv.hostPlatform) system;
              nixConfigPkgs = inputs.nix-config.packages.''${system};
            in {
              home.packages = [ nixConfigPkgs.${name} ]
            }
            ```
          ''
          ++ singleton ''
            ## Source

            [`packages/${name}/package.nix`](${repoRoot}/packages/${name}/package.nix)
          '';

        content = concatStringsSep "\n\n" sections |> writeText "nix-config-doc-package-${name}";
        nuDescription =
          if package ? meta.description
          then "\"${package.meta.description}\""
          else "null";
      in
        # nu
        ''
          cp ${content} ./src/packages/${name}.md
          let chapters = $chapters | append { name: "${name}", description: ${nuDescription} }
        '')
      |> join "\n";
  in
    # nu
    ''
      let chapters = [];

      ${body}

      let summary = $chapters
      | each { $"  - [`($in.name)`]\(./packages/($in.name).md)" }
      | str join "\n"

      let list = $chapters
      | each {
        let description = if $in.description != null {$": ($in.description)"} else {""}
        $"- [`($in.name)`]\(./($in.name).md)($description)"
      }
      | str join "\n"

      open --raw ./src/SUMMARY.md
      | str replace " <!-- packages-summary -->" $"\n($summary)"
      | save --force ./src/SUMMARY.md

      open --raw ./src/packages/README.md
      | str replace "<!-- packages-list -->" $list
      | save --force ./src/packages/README.md
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
        #### Type {#${class}-option-type-${attrText}}

        ${option.type.description}
      ''
      ++ optional (option ? defaultText || option ? default) ''
        #### Default {#${class}-option-default-${attrText}}

        ```nix
        ${defaultText}
        ```
      ''
      ++ optional (option ? example) ''
        #### Example {#${class}-option-example-${attrText}}

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

    ### Usage {#${class}-usage}

    ```nix
    { inputs, ... }: {
      imports = [inputs.nix-dots.${class}Modules.${name}];
    }
    ```

    ### Source {#${class}-source}

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
            let chapters = $chapters | append { name: "${name}" }
          ''
      )
      |> concatStringsSep "\n";
  in
    # nu
    ''
      let chapters = [];

      ${body}

      let summary = $chapters
      | each { $"  - [`($in.name)`]\(./modules/($in.name).md)" }
      | str join "\n"

      let list = $chapters
      | each { $"- [`($in.name)`]\(./($in.name).md)" }
      | str join "\n"

      open --raw ./src/SUMMARY.md
      | str replace " <!-- modules-summary -->" $"\n($summary)"
      | save --force ./src/SUMMARY.md

      open --raw ./src/modules/README.md
      | str replace "<!-- modules-list -->" $list
      | save --force ./src/modules/README.md
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
