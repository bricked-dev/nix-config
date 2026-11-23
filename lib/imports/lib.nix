{
  lib,
  self,
  ...
}: let
  inherit (lib.trivial) flip;
  inherit (self.lib.modules) setModuleContext;
  inherit (self.lib.trivial) applyIfFunction bindArgs bindIntersectArgs callIntersectArgs;
in {
  /**
  Import and evaluate a library. If the imported library is a function, this calls it with `specialArgs`.

  # Type

  ```
  importLib :: a -> Path -> b
  ```

  # Arguments

  specialArgs
  : Arguments to pass to the library.

  path
  : Path to the library.
  */
  importLib = specialArgs: path:
    import path
    |> applyIfFunction (callIntersectArgs specialArgs);

  /**
  Import and evaluate a module. If the imported module is a function, this wraps it in another function that applies `specialArgs` when the module is evaluated.

  # Type

  ```
  importModule :: a -> Path -> b
  ```

  # Arguments

  specialArgs
  : Arguments to bind to the module.

  path
  : Path to the module.
  */
  importModule = specialArgs: class: path:
    import path
    |> applyIfFunction (bindArgs specialArgs)
    |> setModuleContext {
      _class = class;
      _file = path;
    };

  /**
  Import and evaluate a package. If the imported package is a function, this wraps it in another function that applies `specialArgs` when evaluated.

  # Type

  ```
  importPackage :: a -> Path -> b
  ```

  # Arguments

  pkgs
  : The Nixpkgs instance to call the package with.

  specialArgs
  : Arguments to bind to the package.

  path
  : Path to the package.
  */
  importPackage = pkgs: specialArgs: path:
    import path
    |> applyIfFunction (bindIntersectArgs specialArgs)
    |> flip pkgs.callPackage {};
}
