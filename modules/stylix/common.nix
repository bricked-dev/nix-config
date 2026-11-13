{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.stylix;
in {
  config = mkIf cfg.enable {
    stylix = {
      base16Scheme = ./coal.yaml;
      image = inputs.wallpaper;
      polarity = "dark";

      fonts = rec {
        serif = sansSerif;

        sansSerif = {
          package = pkgs.adwaita-fonts;
          name = "Adwaita Sans";
        };

        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
      };
    };
  };
}
