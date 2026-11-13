{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (builtins) readFile;
  inherit (lib.modules) mkIf;
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.programs.anyrun;
  selfPkgs = self.packages.${system};
in {
  config = mkIf cfg.enable {
    programs.anyrun = {
      extraCss = readFile ./style.css;
      extraConfigFiles."power.ron".source = ./power.ron;

      config = {
        closeOnClick = true;

        plugins = [
          "${selfPkgs.anyrun-power-plugin}/lib/libpower.so"
          "${cfg.package}/lib/libapplications.so"
          "${cfg.package}/lib/librink.so"
          "${cfg.package}/lib/libsymbols.so"
        ];
      };
    };
  };
}
