{
  nushell,
  lib,
  writers,
  ...
}: let
  inherit (lib.meta) getExe;
in
  (writers.writeDashBin "nushell-login"
    # See https://wiki.nixos.org/wiki/Nushell#Installation
    ''
      if ! [ "$TERM" = "dumb" ]; then
        exec ${getExe nushell}
      fi
    '').overrideAttrs {
    passthru.shellPath = "/bin/nushell-login";
  }
