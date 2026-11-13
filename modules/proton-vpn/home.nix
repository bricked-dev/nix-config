{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) bool;

  cfg = config.programs.proton-vpn;
in {
  options.programs.proton-vpn = {
    enable = mkEnableOption "the Proton VPN client";
    package = mkPackageOption pkgs "proton-vpn" {};
    cliPackage = mkPackageOption pkgs "proton-vpn-cli" {};

    autostart = mkOption {
      description = "Whether to start the client on login.";
      default = true;
      example = false;
      type = bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package cfg.cliPackage];

    xdg.autostart = mkIf cfg.autostart {
      enable = true;
      entries = ["${cfg.package}/share/applications/proton.vpn.app.gtk.desktop"];
    };
  };
}
