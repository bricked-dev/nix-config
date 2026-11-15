{
  pkgs,
  inputs,
  self,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  diskoPkgs = inputs.disko.packages.${system};
  selfPkgs = self.packages.${system};
in {
  imports = [
    self.nixosModules.all
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
    ./hardware.nix
    ./disko.nix
  ];

  # System
  networking.hostName = "broccoli";
  time.timeZone = "Europe/Berlin";

  # Users
  users.users = {
    bricked = {
      isNormalUser = true;
      description = "Bricked";
      extraGroups = ["networkmanager" "wheel"];
    };
  };

  # Nix
  environment.etc."nixos".source = self.outPath;
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";

  nix = {
    gc.automatic = true;
    settings.trusted-users = ["@wheel"];
  };

  # Boot
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    lanzaboote.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = true;
    zswap.enable = true;
  };

  # Input
  services.xserver.xkb.layout = "us";

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
  };

  # Desktop
  stylix.enable = true;
  services.displayManager.gdm.enable = true;
  services.gremlin-shell.enable = true;
  programs.mango.enable = true;

  # Shell
  console.useXkbConfig = true;
  programs.nushell.enable = true;
  users.defaultUserShell = selfPkgs.nushell-login;

  environment.systemPackages = [
    diskoPkgs.disko
    pkgs.libadwaita.devdoc
    pkgs.alejandra
    pkgs.bitwarden-desktop
    pkgs.fd
    pkgs.home-manager
    pkgs.nix-melt
    pkgs.nurl
    pkgs.ripgrep
  ];
}
