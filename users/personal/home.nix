{self, ...}: {
  imports = [self.homeModules.all];

  # Nix
  nixpkgs.config.allowUnfree = true;
  programs.nix-your-shell.enable = true;

  # Home
  programs.home-manager.enable = true;

  home = {
    stateVersion = "26.05";
    username = "personal";
    homeDirectory = "/home/personal";
    keyboard.layout = "de";
  };

  # Theming
  stylix.enable = true;
  wayland.windowManager.mango.enable = true;
  services.gremlin-shell.enable = true;

  # Shell
  programs.difftastic.enable = true;
  programs.direnv.enable = true;
  programs.git.enable = true;
  programs.gpg.enable = true;
  programs.mergiraf.enable = true;
  programs.nushell.enable = true;
  programs.starship.enable = true;
  programs.tealdeer.enable = true;
  programs.zoxide.enable = true;

  # Editor
  programs.vscodium.enable = true;

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  # Apps
  programs.ghostty.enable = true;
  programs.librewolf.enable = true;
  programs.proton-vpn.enable = true;
  programs.rust.enable = true;
}
