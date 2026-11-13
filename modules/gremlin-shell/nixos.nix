{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.services.gremlin-shell;
in {
  imports = [inputs.gremlin-shell.nixosModules.default];

  config = mkIf cfg.enable {
    services.gremlin-shell.programs.development.enable = true;
  };
}
