{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.profiles.gaming;
in {
  options.profiles.gaming = {
    enable = mkEnableOption "the gaming profile";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    programs.gamemode.enable = true;
  };
}
