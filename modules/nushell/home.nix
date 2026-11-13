{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.programs.nushell;
in {
  config = mkIf cfg.enable {
    programs.nushell = {
      environmentVariables = {
        PROMPT_INDICATOR_VI_NORMAL = "";
        PROMPT_INDICATOR_VI_INSERT = "";
      };

      settings = {
        buffer_editor = "hx";
        cursor_shape.helix_insert = "line";
        cursor_shape.helix_normal = "block";
        edit_mode = "helix";
        rm.always_trash = true;
        show_banner = false;

        abbreviations = {
          # Unix
          cpr = "cp --recursive";

          # Nix
          nb = "nix build";
          nfs = "nix flake show";
          nfu = "nix flake update";
          nl = "nix-locate";
          nm = "nix-melt";
          nr = "nix run";
          nrp = "nix repl .";
          ns = "nix shell";

          # NixOS
          nrs = "nixos-rebuild switch --sudo --flake .";
          nrt = "nixos-rebuild test --sudo --flake .";

          # Home Manager
          hmn = "home-manager news --flake .";
          hms = "home-manager switch -b backup --flake .";
          hmsn = "home-manager switch -b backup --flake /etc/nixos";

          # Git
          ga = "git add";
          gaa = "git add .";
          gap = "git add --patch";
          gc = "git commit";
          gca = "git commit --amend";
          gcan = "git commit --amend --no-edit";
          gcm = "git commit --message";
          gcp = "git cherry-pick";
          gcpa = "git cherry-pick --abort";
          gd = "git diff";
          gdc = "git diff --cached";
          gdcn = "git diff --cached --name-only";
          gdh = "git diff HEAD~ HEAD";
          gdhn = "git diff --name-only HEAD~ HEAD";
          gdn = "git diff --name-only";
          gf = "git fetch";
          gl = "git log";
          glo = "git log --oneline";
          gm = "git merge";
          gmc = "git merge --continue";
          gma = "git merge --abort";
          gp = "git push";
          gpf = "git push --force";
          gpl = "git pull";
          gr = "git rebase";
          gra = "git rebase --abort";
          grc = "git rebase --continue";
          gri = "git rebase --interactive";
          grir = "git rebase --interactive --root";
          gs = "git switch";
          gsc = "git switch --create";
        };
      };
    };
  };
}
