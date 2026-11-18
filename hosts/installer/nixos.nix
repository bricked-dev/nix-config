{
  inputs,
  pkgs,
  self,
  ...
}: {
  imports = [
    self.diskoConfigurations.carrot
    self.nixosModules.console
    self.nixosModules.desktop
    self.nixosModules.stylix
    self.nixosModules.system
  ];

  # Profiles
  profiles.console.enable = true;
  profiles.desktop.enable = true;
  profiles.system.enable = true;
  stylix.enable = true;

  # Image
  image.modules.iso-installer.isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # System
  networking.hostName = "installer";
  services.xserver.xkb.layout = "us";

  # Users
  users.users.nixos = {
    description = "NixOS";
    isNormalUser = true;
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs self;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nixos = ./home.nix;
  };

  # Boot
  boot = {
    silent = false;
    supportedFilesystems.zfs = false;
  };

  # Login
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
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
}
