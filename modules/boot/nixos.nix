{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.boot;
in {
  options.boot.silent = mkEnableOption "silent boot";

  config = mkIf cfg.silent {
    boot = {
      # See https://wiki.nixos.org/wiki/Plymouth#Basic_Config
      consoleLogLevel = 3;
      loader.timeout = 0;

      kernelParams = [
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}
