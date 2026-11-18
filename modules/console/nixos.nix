{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (pkgs.stdenv.hostPlatform) system;

  diskoPkgs = inputs.disko.packages.${system};
  selfPkgs = self.packages.${system};

  cfg = config.profiles.console;
in {
  imports = [
    self.nixosModules.rust
  ];

  options.profiles.console = {
    enable = mkEnableOption "the console profile";
  };

  config = mkIf cfg.enable {
    console.useXkbConfig = true;
    programs.nushell.enable = true;
    users.defaultUserShell = selfPkgs.nushell-login;

    # Programs
    programs.rust.enable = true;

    environment.systemPackages = [
      diskoPkgs.disko
      pkgs.alejandra
      pkgs.bacon
      pkgs.cargo-flamegraph
      pkgs.git
      pkgs.home-manager
      pkgs.home-manager
      pkgs.nix-melt
      pkgs.nurl
      pkgs.ripgrep
    ];
  };
}
