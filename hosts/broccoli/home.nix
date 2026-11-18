{self, ...}: {
  imports = [self.homeModules.desktop self.homeModules.console self.homeModules.stylix self.homeModules.system];

  home.keyboard.layout = "us";
  profiles.desktop.enable = true;
  profiles.console.enable = true;
  profiles.system.enable = true;
  stylix.enable = true;
}
