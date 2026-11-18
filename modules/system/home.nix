{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.profiles.system;
in {
  options.profiles.system = {
    enable = mkEnableOption "the system profile";
  };

  config = mkIf cfg.enable {
    programs.home-manager.enable = true;

    home = {
      stateVersion = "26.11";
      homeDirectory = mkDefault "/home/${config.home.username}";
    };
  };
}
