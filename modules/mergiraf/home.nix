{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.programs.mergiraf;
in {
  config = mkIf cfg.enable {
    programs.mergiraf.enableGitIntegration = true;
  };
}
