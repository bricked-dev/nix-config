{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.services.printing;
in {
  config = mkIf cfg.enable {
    services.printing.drivers = [pkgs.hplip];
  };
}
