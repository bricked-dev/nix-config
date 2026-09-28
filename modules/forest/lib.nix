{lib, ...}: let
  inherit (builtins) attrNames functionArgs intersectAttrs mapAttrs pathExists;
  inherit (lib) filterAttrs flip isFunction optionalAttrs pathIsRegularFile readDir setFunctionArgs;
  inherit (lib.path) append;
in rec {
  setModuleContext = context: module:
    context // {imports = [module];};

  applyIfFunction = fn: value:
    if isFunction value
    then fn value
    else value;

  bindArgs = specialArgs: module:
    setFunctionArgs
    (args: module (args // specialArgs))
    (removeAttrs (functionArgs module) (attrNames specialArgs));

  bindIntersectArgs = specialArgs: module:
    bindArgs
    (intersectAttrs (functionArgs module) specialArgs)
    module;

  resolveDefault = root: name: let
    path = append root "${name}.nix";
  in
    optionalAttrs (pathIsRegularFile path) {
      default = path;
    };

  resolveNested = root: name:
    optionalAttrs (pathExists root) (
      readDir root
      |> mapAttrs (attr: _type: append (append root attr) "${name}.nix")
      |> filterAttrs (_attr: pathIsRegularFile)
    );

  transformLib = specialArgs: path:
    import path
    |> applyIfFunction (lib: bindIntersectArgs specialArgs lib {});

  transformModule = specialArgs: class: path:
    import path
    |> applyIfFunction (bindArgs specialArgs)
    |> setModuleContext {
      _class = class;
      _file = path;
    };

  transformPackage = pkgs: specialArgs: path:
    import path
    |> applyIfFunction (bindIntersectArgs specialArgs)
    |> flip pkgs.callPackage {};
}
