{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;

  cfg = config.services.awww;
in {
  config = mkIf cfg.enable {
    systemd.user.services.configure-awww = {
      Install.WantedBy = [config.wayland.systemd.target];

      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "awww-daemon";
        After = [config.wayland.systemd.target "awww.service"];
        PartOf = [config.wayland.systemd.target];
      };

      Service = {
        ExecStart = "${getExe cfg.package} img ${inputs.wallpaper}";
        Restart = "on-failure";
      };
    };
  };
}
