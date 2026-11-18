{
  config,
  lib,
  inputs,
  self,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.stylix;
in {
  imports = [
    inputs.stylix.nixosModules.stylix
    self.commonModules.stylix
  ];

  config = mkIf cfg.enable {
    stylix = {
      homeManagerIntegration.autoImport = false;

      targets = {
        gtksourceview.enable = false;
        plymouth.enable = false;
        qt.enable = true;
      };
    };
  };
}
