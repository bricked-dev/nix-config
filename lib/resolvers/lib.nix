{lib, ...}: let
  inherit (builtins) mapAttrs readDir;
  inherit (lib.attrsets) filterAttrs;
  inherit (lib.filesystem) pathIsRegularFile;
  inherit (lib.path) append;
in {
  /**
  Resolve modules in a module directory.

  # Type

  ```
  resolve :: Path -> String -> AttrSet
  ```

  # Arguments

  root
  : Directory path containing the modules.

  name
  : Name of the module files.
  */
  resolve = root: let
    rootEntries = readDir root;
  in
    name:
      mapAttrs (entry: _type: append (append root entry) "${name}.nix") rootEntries
      |> filterAttrs (_attr: pathIsRegularFile);
}
