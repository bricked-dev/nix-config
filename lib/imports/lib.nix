{
  lib,
  self,
  ...
}: let
  inherit (lib.trivial) flip;
  inherit (self.lib.modules) setModuleContext;
  inherit (self.lib.trivial) applyIfFunction bindArgs bindIntersectArgs callIntersectArgs;
in {
  importLib = specialArgs: path:
    import path
    |> applyIfFunction (callIntersectArgs specialArgs);

  importModule = specialArgs: class: path:
    import path
    |> applyIfFunction (bindArgs specialArgs)
    |> setModuleContext {
      _class = class;
      _file = path;
    };

  importPackage = pkgs: specialArgs: path:
    import path
    |> applyIfFunction (bindIntersectArgs specialArgs)
    |> flip pkgs.callPackage {};
}
