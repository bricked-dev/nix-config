{
  config,
  inputs,
  lib,
  self,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.profiles.desktop;
in {
  imports = [
    inputs.gremlin-shell.homeModules.gremlin-shell
    self.homeModules.anyrun
    self.homeModules.awww
    self.homeModules.ghostty
    self.homeModules.librewolf
    self.homeModules.mango
    self.homeModules.proton-vpn
  ];

  options.profiles.desktop = {
    enable = mkEnableOption "the desktop profile";
  };

  config = mkIf cfg.enable {
    services.awww.enable = true;
    services.gremlin-shell.enable = true;
    wayland.windowManager.mango.enable = true;

    # Programs
    programs.ghostty.enable = true;
    programs.librewolf.enable = true;
    programs.proton-vpn.enable = true;
  };
}
