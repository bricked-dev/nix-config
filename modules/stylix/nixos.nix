{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.stylix;
in {
  imports = [
    ./common.nix
    inputs.stylix.nixosModules.stylix
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
