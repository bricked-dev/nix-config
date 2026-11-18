{
  config,
  lib,
  inputs,
  pkgs,
  self,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.stylix;
in {
  imports = [
    inputs.stylix.homeModules.stylix
    self.commonModules.stylix
  ];

  config = mkIf cfg.enable {
    stylix = {
      icons = {
        enable = true;
        package = pkgs.morewaita-icon-theme;
        light = "MoreWaita";
        dark = "MoreWaita";
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };

      targets = {
        qt = {
          enable = true;
          standardDialogs = "xdgdesktopportal";
        };

        librewolf = {
          profileNames = ["default"];
          firefoxGnomeTheme.enable = true;
        };
      };
    };
  };
}
