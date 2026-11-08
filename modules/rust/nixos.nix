{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption optional types;

  cfg = config.programs.rust;
in {
  imports = [./common.nix];

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package] ++ optional cfg.docs.enable cfg.docs.package;
  };
}
