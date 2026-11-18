{lib, ...}: let
  inherit (builtins) attrNames functionArgs intersectAttrs isFunction;
  inherit (lib.trivial) setFunctionArgs;
in rec {
  applyIfFunction = fn: value:
    if isFunction value
    then fn value
    else value;

  bindArgs = specialArgs: fn:
    setFunctionArgs
    (args: fn (args // specialArgs))
    (removeAttrs (functionArgs fn) (attrNames specialArgs));

  bindIntersectArgs = specialArgs: fn:
    bindArgs
    (intersectAttrs (functionArgs fn) specialArgs)
    fn;

  callIntersectArgs = args: fn: fn (intersectAttrs (functionArgs fn) args);
}
