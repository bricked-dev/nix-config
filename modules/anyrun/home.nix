{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (builtins) readFile;
  inherit (lib) mkIf;

  cfg = config.programs.anyrun;
  selfPkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  config = mkIf cfg.enable {
    programs.anyrun = {
      config = {
        closeOnClick = true;

        plugins = [
          "${selfPkgs.anyrun-power-plugin}/lib/libpower.so"
          "${cfg.package}/lib/libapplications.so"
          "${cfg.package}/lib/librink.so"
          "${cfg.package}/lib/libsymbols.so"
        ];
      };

      extraCss = readFile ./style.css;
      extraConfigFiles."power.ron".source = ./power.ron;
    };
  };
}
