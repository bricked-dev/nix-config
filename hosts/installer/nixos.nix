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
  imports = [self.nixosModules.all];

  # Image
  image.modules.iso-installer.isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # System
  networking.hostName = "installer";
  environment.etc."nixos".source = self.outPath;
  system.stateVersion = "26.05";
  nix.settings.trusted-users = ["@wheel"];

  # Users
  users.users.nixos.description = "NixOS";

  home-manager = {
    extraSpecialArgs = {inherit inputs self;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nixos = ./home.nix;
  };

  # Boot
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    plymouth.enable = true;
    supportedFilesystems.zfs = false;
  };

  # Login
  services.displayManager = {
    gdm.enable = true;

    autoLogin = {
      enable = true;
      user = "nixos";
    };
  };

  system.activationScripts.configureAccountsService.text = let
    text =
      pkgs.writeText "accounts-service-config"
      # ini
      ''
        [User]
        Session=mango-uwsm
        Icon=/home/nixos/.face
        SystemAccount=false
      '';
  in ''
    install -D "${text}" "/var/lib/AccountsService/users/nixos"
  '';

  # Desktop
  programs.mango.enable = true;
  services.gremlin-shell.enable = true;
  services.xserver.xkb.layout = "us";
  stylix.enable = true;

  # Shell
  console.useXkbConfig = true;
  programs.nushell.enable = true;
  users.defaultUserShell = selfPkgs.nushell-login;

  # Programs
  environment.systemPackages = [diskoPkgs.disko pkgs.home-manager];
}
