{
  nushell,
  lib,
  writers,
}: let
  inherit (lib) maintainers;
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

    meta = {
      description = "Login shell wrapper for Nushell";
      mainProgram = "nushell-login";
      maintainers = [maintainers.bricked];
    };
  }
