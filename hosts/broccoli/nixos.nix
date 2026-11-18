{
  inputs,
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
  ];

  profiles.console.enable = true;
  profiles.desktop.enable = true;
  profiles.system.enable = true;
  stylix.enable = true;

  networking.hostName = "broccoli";
  services.xserver.xkb.layout = "us";

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
}
