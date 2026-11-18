{lib, ...}: let
  inherit (builtins) mapAttrs readDir;
  inherit (lib.attrsets) filterAttrs;
  inherit (lib.filesystem) pathIsRegularFile;
  inherit (lib.path) append;
in {
  resolve = root: let
    rootEntries = readDir root;
  in
    name:
      mapAttrs (entry: _type: append (append root entry) "${name}.nix") rootEntries
      |> filterAttrs (_attr: pathIsRegularFile);
}
