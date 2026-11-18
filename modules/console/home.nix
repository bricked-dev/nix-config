{
  config,
  lib,
  self,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.profiles.console;
in {
  imports = [
    self.homeModules.difftastic
    self.homeModules.git
    self.homeModules.helix
    self.homeModules.mergiraf
    self.homeModules.nushell
    self.homeModules.rust
    self.homeModules.starship
  ];

  options.profiles.console = {
    enable = mkEnableOption "the console profile";
  };

  config = mkIf cfg.enable {
    programs.carapace.enable = true;
    programs.difftastic.enable = true;
    programs.direnv.enable = true;
    programs.git.enable = true;
    programs.gpg.enable = true;
    programs.mergiraf.enable = true;
    programs.nix-your-shell.enable = true;
    programs.nushell.enable = true;
    programs.rust.enable = true;
    programs.starship.enable = true;
    programs.tealdeer.enable = true;
    programs.zoxide.enable = true;

    programs.helix = {
      enable = true;
      defaultEditor = true;
    };
  };
}
