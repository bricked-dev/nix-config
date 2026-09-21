{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption optional types;

  cfg = config.programs.rust;
in {
  imports = [./common.nix];

  options.programs.rust = {
    docs.server = {
      enable =
        mkEnableOption "local documentation server"
        // {
          default = true;
        };

      hostName = mkOption {
        description = "Hostname for the documentation server.";
        type = types.str;
        default = "rust.docs.localhost";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package] ++ optional cfg.docs.enable cfg.docs.package;

    services.caddy = mkIf cfg.docs.server.enable {
      enable = true;

      virtualHosts.${cfg.docs.server.hostName}.extraConfig = ''
        root ${config.programs.rust.package}/share/doc/rust/html
        file_server
      '';
    };
  };
}
