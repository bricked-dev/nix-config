{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.nix;
in {
  config = mkIf cfg.enable {
    nix = {
      settings.experimental-features = ["nix-command" "flakes" "pipe-operators"];

      gc = mkIf cfg.gc.automatic {
        dates = "weekly";
        options = "--delete-older-than 30d";
        persistent = true;
      };
    };
  };
}
