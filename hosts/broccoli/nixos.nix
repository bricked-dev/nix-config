{
  inputs,
  pkgs,
  self,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
    self.diskoConfigurations.carrot
    self.nixosModules.broccoli-hardware
    self.nixosModules.console
    self.nixosModules.desktop
    self.nixosModules.stylix
    self.nixosModules.system
    self.usersConfigurations.broccoli
  ];

  profiles.console.enable = true;
  profiles.desktop.enable = true;
  profiles.system.enable = true;
  stylix.enable = true;

  networking.hostName = "broccoli";
  services.xserver.xkb.layout = "us";

  environment.systemPackages = [pkgs.geteduroam];
}
