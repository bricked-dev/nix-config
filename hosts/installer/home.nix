{self, ...}: {
  imports = [self.homeModules.all];

  # Home
  home = {
    stateVersion = "26.11";
    username = "nixos";
    homeDirectory = "/home/nixos";
    keyboard.layout = "us";
  };

  # Desktop
  wayland.windowManager.mango.enable = true;
  services.gremlin-shell.enable = true;

  stylix = {
    enable = true;
    overlays.enable = false;
  };

  # Programs
  programs.ghostty.enable = true;
  programs.home-manager.enable = true;

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  # Shell
  programs.carapace.enable = true;
  programs.difftastic.enable = true;
  programs.direnv.enable = true;
  programs.git.enable = true;
  programs.gpg.enable = true;
  programs.mergiraf.enable = true;
  programs.nix-your-shell.enable = true;
  programs.nushell.enable = true;
  programs.starship.enable = true;
  programs.tealdeer.enable = true;
  programs.zoxide.enable = true;
}
