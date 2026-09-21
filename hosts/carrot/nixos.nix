{
  pkgs,
  inputs,
  self,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  agenixPkgs = inputs.agenix.packages.${system};
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
  };

  # Nix
  environment.etc."nixos".source = self.outPath;
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };

    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel"];
    };
  };

  # Boot
  boot = {
    initrd.systemd.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = true;
    silent = true;

    kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=lz4"
      "zswap.max_pool_percent=25"
      "zswap.shrinker_enabled=1"
    ];

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  # Networking
  services.openssh = {
    enable = true;
    openFirewall = false;
    listenAddresses = [];

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
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
  programs.mango.enable = true;

  services.gremlin-shell = {
    enable = true;
    applications.enableCore = true;
    applications.enableDeveloper = true;
  };

  # Shell
  console.useXkbConfig = true;

  programs.nushell = {
    enable = true;
    defaultUserShell = true;
  };

  # Programs
  programs.adwaita-demo.enable = true;
  programs.rust.enable = true;
  programs.spicetify.enable = true;
  programs.steam.enable = true;

  environment.systemPackages = [
    agenixPkgs.agenix
    diskoPkgs.disko
    pkgs.alejandra
    pkgs.bacon
    pkgs.bitwarden-desktop
    pkgs.cargo-flamegraph
    pkgs.fd
    pkgs.gcc
    pkgs.home-manager
    pkgs.nix-melt
    pkgs.nurl
    pkgs.proton-vpn
    pkgs.ripgrep
    pkgs.sbctl
    pkgs.signal-desktop
    pkgs.tuba
    pkgs.typesetter
    pkgs.typst
    pkgs.vesktop
    pkgs.whatsapp-electron
    pkgs.krita
  ];
}
