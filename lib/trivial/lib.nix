{
  lib,
  self,
  ...
}: let
  inherit (builtins) attrNames functionArgs intersectAttrs isFunction;
  inherit (lib.trivial) setFunctionArgs;
  inherit (self.lib.trivial) bindArgs;
in {
  /**
  Apply a function to a value if it is also a function.

  # Type

  ```
  applyIfFunction :: ((a -> b) -> c) -> (a -> b) -> c
  applyIfFunction :: ((a -> b) -> c) -> d -> d
  ```

  # Arguments

  fn
  : Function to apply.

  value
  : Value to apply the function to, if it is also a function.
  */
  applyIfFunction = fn: value:
    if isFunction value
    then fn value
    else value;

  /**
  Bind arguments to a function. This wraps the function in another function that applies `specialArgs` when called.

  # Type

  ```
  bindArgs :: a -> (b -> c) -> (d -> c)
  ```

  # Arguments

  specialArgs
  : Arguments to bind to the function.

  fn
  : Function to bind to.
  */
  bindArgs = specialArgs: fn:
    setFunctionArgs
    (args: fn (args // specialArgs))
    (removeAttrs (functionArgs fn) (attrNames specialArgs));

  /**
  Bind arguments to a function, passing only arguments the function explicitly takes. This wraps the function in another function that applies the attributes of `specialArgs` present in the function's parameter list when called.

  # Type

  ```
  bindIntersectArgs :: a -> (b -> c) -> (d -> c)
  ```

  # Arguments

  specialArgs
  : Arguments to bind to the function.

  path
  : Function to bind to.
  */
  bindIntersectArgs = specialArgs: fn:
    bindArgs
    (intersectAttrs (functionArgs fn) specialArgs)
    fn;

  /**
  Calls a function, passing only arguments the function explicitly takes. This calls the function with the attributes of `specialArgs` present in the function's parameter list.

  # Type

  ```
  callIntersectArgs :: a -> (b -> c) -> (d -> c)
  ```

  # Arguments

  specialArgs
  : Arguments to pass to the function.

  path
  : Function to call.
  */
  callIntersectArgs = args: fn: fn (intersectAttrs (functionArgs fn) args);
}
