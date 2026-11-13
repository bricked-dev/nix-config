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
    boot.lanzaboote.pkiBundle = mkDefault "/var/lib/sbctl";

    environment.systemPackages = [pkgs.sbctl];
  };
}
