{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkDefault mkIf;

  cfg = config.boot.lanzaboote;
in {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  config = mkIf cfg.enable {
    boot.lanzaboote = {
      autoGenerateKeys.enable = true;
      pkiBundle = mkDefault "/var/lib/sbctl";

      autoEnrollKeys = {
        enable = true;
        includeFirmwareBuiltinKeys = true;
      };
    };

    environment.systemPackages = [pkgs.sbctl];
  };
}
