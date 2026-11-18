{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.profiles.system;
in {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    self.nixosModules.boot
    self.nixosModules.lanzaboote
    self.nixosModules.nix
  ];

  options.profiles.system = {
    enable = mkEnableOption "the system profile";
  };

  config = mkIf cfg.enable {
    # System
    environment.etc."nixos".source = self.outPath;
    home-manager.backupFileExtension = "backup";
    system.stateVersion = mkDefault "26.11";
    time.timeZone = mkDefault "Europe/Berlin";

    # Nix
    nix = {
      gc.automatic = mkDefault true;
      settings.trusted-users = ["@wheel"];
    };

    # Boot
    boot = {
      kernelPackages = mkDefault pkgs.linuxPackages_latest;
      lanzaboote.enable = mkDefault true;
      loader.efi.canTouchEfiVariables = mkDefault true;
    };
  };
}
