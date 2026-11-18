{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.profiles.desktop;
in {
  imports = [
    self.nixosModules.gremlin-shell
    self.nixosModules.mango
  ];

  options.profiles.desktop = {
    enable = mkEnableOption "the desktop profile";
  };

  config = mkIf cfg.enable {
    programs.mango.enable = true;
    services.displayManager.gdm.enable = true;
    services.gremlin-shell.enable = true;

    # Boot
    boot = {
      plymouth.enable = true;
      silent = true;
    };

    # Input
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
    };

    # Printing
    services.avahi.enable = true;
    services.printing.enable = true;

    # Programs
    environment.systemPackages = [
      pkgs.bitwarden-desktop
      pkgs.fractal
      pkgs.tuba
      pkgs.vesktop
      pkgs.wl-clipboard-rs
    ];
  };
}
