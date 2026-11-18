{
  config,
  lib,
  self,
  ...
}: let
  inherit (lib) mkIf optional;

  cfg = config.programs.rust;
in {
  imports = [self.commonModules.rust];

  config = mkIf cfg.enable {
    home.packages = [cfg.package] ++ optional cfg.docs.enable cfg.docs.package;
  };
}
