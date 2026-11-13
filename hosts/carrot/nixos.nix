{
  pkgs,
  inputs,
  self,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  diskoPkgs = inputs.disko.packages.${system};
in {
  imports = [
    self.nixosModules.all
    ./hardware.nix
    ./disko.nix
  ];

  # System
  networking.hostName = "carrot";
  time.timeZone = "Europe/Berlin";

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

    gaming = {
      isNormalUser = true;
      description = "Gaming";
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
    lanzaboote.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = true;
    zswap.enable = true;
  };

  # Printing
  services.avahi.enable = true;

  services.printing = {
    enable = true;
    drivers = [pkgs.hplip];
  };

  # Input
  boot.kernelModules = ["uinput"];
  hardware.opentabletdriver.enable = true;
  hardware.uinput.enable = true;
  services.xserver.xkb.layout = "de";

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

  programs.nushell = {
    enable = true;
    defaultUserShell = true;
  };

  # Programs
  programs.rust.enable = true;
  programs.spicetify.enable = true;
  programs.steam.enable = true;

  environment.systemPackages = [
    diskoPkgs.disko
    pkgs.libadwaita.devdoc
    pkgs.alejandra
    pkgs.bacon
    pkgs.bitwarden-desktop
    pkgs.cargo-flamegraph
    pkgs.fd
    pkgs.fractal
    pkgs.gcc
    pkgs.home-manager
    pkgs.krita
    pkgs.nix-melt
    pkgs.nurl
    pkgs.ripgrep
    pkgs.tuba
    pkgs.typst
    pkgs.vesktop
  ];
}
