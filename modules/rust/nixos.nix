{
  config,
  lib,
  self,
  ...
}: let
  inherit (lib.lists) optional;
  inherit (lib.modules) mkIf;

  cfg = config.programs.rust;
in {
  imports = [self.commonModules.rust];

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package] ++ optional cfg.docs.enable cfg.docs.package;
  };
}
