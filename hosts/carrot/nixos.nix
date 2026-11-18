{self, ...}: {
  imports = [
    self.diskoConfigurations.carrot
    self.nixosModules.carrot-hardware
    self.nixosModules.console
    self.nixosModules.desktop
    self.nixosModules.stylix
    self.nixosModules.system
  ];

  profiles.console.enable = true;
  profiles.desktop.enable = true;
  profiles.system.enable = true;
  stylix.enable = true;

  networking.hostName = "carrot";
  services.xserver.xkb.layout = "de";

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
}
