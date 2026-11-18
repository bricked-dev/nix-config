{self, ...}: {
  imports = [
    self.diskoConfigurations.carrot
    self.nixosModules.carrot-hardware
    self.nixosModules.console
    self.nixosModules.desktop
    self.nixosModules.stylix
    self.nixosModules.system
    self.usersConfigurations.carrot
  ];

  profiles.console.enable = true;
  profiles.desktop.enable = true;
  profiles.system.enable = true;
  stylix.enable = true;

  networking.hostName = "carrot";
  services.xserver.xkb.layout = "de";
}
