{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.boot.plymouth;
in {
  config = mkIf cfg.enable {
    boot = {
      # Enable "Silent Boot"
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
