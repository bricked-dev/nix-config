{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.programs.difftastic;
in {
  config = mkIf cfg.enable {
    programs.difftastic.git.enable = true;
  };
}
