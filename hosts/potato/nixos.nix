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
    ./hardware.nix
    ./disko.nix
  ];

  # System
  networking.hostName = "potato";

  # Users
  users.users = {
    bricked = {
      isNormalUser = true;
      description = "Bricked";
      extraGroups = ["networkmanager" "wheel"];
    };

    personal = {
      isNormalUser = true;
      description = "Personal";
      extraGroups = ["networkmanager" "wheel"];
    };
  };

  # Nix
  environment.etc."nixos".source = self.outPath;
  system.stateVersion = "26.11";
  nixpkgs.config.allowUnfree = true;

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
    silent = true;
    zswap.enable = true;
  };

  # Theming
  stylix.enable = true;

  # Locale
  time.timeZone = "Europe/Berlin";
  services.xserver.xkb.layout = "de";

  # Desktop
  services.displayManager.gdm.enable = true;
  services.gremlin-shell.enable = true;
  programs.mango.enable = true;

  # Shell
  console.useXkbConfig = true;
  programs.nushell.enable = true;
  users.defaultUserShell = selfPkgs.nushell-login;

  # Programs
  programs.adwaita-demo.enable = true;
  programs.rust.enable = true;
  programs.spicetify.enable = true;

  environment.systemPackages = [
    diskoPkgs.disko
    pkgs.alejandra
    pkgs.bacon
    pkgs.cargo-flamegraph
    pkgs.fd
    pkgs.gcc
    pkgs.home-manager
    pkgs.nix-melt
    pkgs.nurl
    pkgs.ripgrep
    pkgs.tuba # Mastodon client
    pkgs.vesktop # Discord client
  ];
}
