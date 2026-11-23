{
  description = "My Nix configuration";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({
      lib,
      self,
      ...
    }: let
      inherit (builtins) attrNames concatLists intersectAttrs listToAttrs mapAttrs;
      inherit (inputs.home-manager.lib) homeManagerConfiguration;
      inherit (lib) nixosSystem;
      inherit (lib.fixedPoints) fix;
      inherit (lib.attrsets) mapAttrs' mapAttrsToList nameValuePair unionOfDisjoint;
      inherit (lib.modules) mkDefault;
      inherit (self.lib.imports) importLib importModule importPackage;
      inherit (self.lib.resolvers) resolve;

      systems = import inputs.systems;

      # Resolvers
      resolveHosts = resolve ./hosts;
      resolveModules = resolve ./modules;
      resolvePackages = resolve ./packages;
      resolveUsers = resolve ./users;

      # Resolved modules
      homeUserModules = resolveUsers "home";
      homeHostModules = resolveHosts "home";
      nixosHostModules = resolveHosts "nixos";

      hardwareHostModules =
        resolveHosts "hardware"
        |> mapAttrs' (name: value: nameValuePair (name + "-hardware") value);

      homeUserHostModules =
        self.usersConfigurations
        |> mapAttrs (
          hostName: config:
            config.users.users
            |> mapAttrs (userName: _user: {
              imports = [
                (self.homeModules.${userName} or {})
                (self.homeModules."${userName}@${hostName}" or {})
                (self.homeModules.${hostName} or {})
                {
                  home.username = mkDefault userName;
                }
              ];
            })
        );

      # Special args
      recursiveSpecialArgs = specialArgs: fix (self: specialArgs // {specialArgs = self;});
      specialLibArgs = recursiveSpecialArgs {inherit inputs lib self;};
      specialModuleArgs = specialLibArgs;

      # Importers
      importLib' = importLib specialLibArgs;
      importModule' = importModule specialModuleArgs;
    in {
      imports = [
        inputs.disko.flakeModules.disko
        inputs.git-hooks.flakeModule
        inputs.home-manager.flakeModules.home-manager
        inputs.treefmt-nix.flakeModule
      ];

      inherit systems;

      flake = {
        lib = {
          imports = import ./lib/imports/lib.nix specialLibArgs;
          modules = importLib' ./lib/modules/lib.nix;
          options = importLib' ./lib/options/lib.nix;
          resolvers = importLib' ./lib/resolvers/lib.nix;
          trivial = import ./lib/trivial/lib.nix specialLibArgs;
        };

        # Configurations
        diskoConfigurations =
          resolveHosts "disko"
          |> mapAttrs (_name: importLib');

        usersConfigurations =
          resolveHosts "users"
          |> mapAttrs (_name: importLib');

        # Modules
        commonModules =
          resolveModules "common"
          |> mapAttrs (_name: importModule' null);

        homeModules =
          unionOfDisjoint (resolveModules "home") homeUserModules
          |> unionOfDisjoint homeHostModules
          |> mapAttrs (_name: importModule' "homeManager");

        nixosModules =
          unionOfDisjoint (resolveModules "nixos") nixosHostModules
          |> unionOfDisjoint hardwareHostModules
          |> mapAttrs (_name: importModule' "nixos");
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        specialPackageArgs = specialLibArgs;
        importPackage' = importPackage pkgs specialPackageArgs;

        homeConfigurations =
          homeUserHostModules
          |> mapAttrsToList (
            hostName:
              mapAttrsToList (userName: module:
                nameValuePair
                "${userName}@${hostName}"
                (homeManagerConfiguration {
                  inherit pkgs;
                  modules = [module];
                }))
          )
          |> concatLists
          |> listToAttrs;

        nixosPlainConfigurations =
          nixosHostModules
          |> mapAttrs (hostName: _path:
            nixosSystem {
              inherit system;
              modules = [self.nixosModules.${hostName}];
            });

        nixosHomesConfigurations =
          nixosHostModules
          |> intersectAttrs homeUserHostModules
          |> attrNames
          |> map (hostName:
            nameValuePair
            "${hostName}-homes"
            (nixosSystem {
              inherit system;
              modules = [
                self.nixosModules.${hostName}
                {home-manager.users = homeUserHostModules.${hostName};}
              ];
            }))
          |> listToAttrs;
      in {
        legacyPackages = {
          inherit homeConfigurations;
          nixosConfigurations = unionOfDisjoint nixosHomesConfigurations nixosPlainConfigurations;
        };

        packages =
          resolvePackages "package"
          |> mapAttrs (_name: importPackage');

        # Shell
        devShells.default = config.pre-commit.devShell;

        pre-commit.settings = {
          hooks.treefmt.enable = true;
        };

        treefmt.config = {
          flakeCheck = false;
          projectRootFile = "flake.nix";

          programs = {
            actionlint.enable = true;
            alejandra.enable = true;
            prettier.enable = true;
            rustfmt.enable = true;
            statix.enable = true;
          };
        };
      };
    });

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://bricked.cachix.org"
    ];

    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "bricked.cachix.org-1:SPpNjrCYzlfisekwWTN7dEUQs+OrirrM92h1ZoEnciY="
    ];
  };

  inputs = {
    flake-compat.url = "github:edolstra/flake-compat";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    systems.url = "github:nix-systems/default-linux";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "git+https://gitlab.com/rycee/nur-expressions.git?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-extensions-declarative = {
      url = "github:firefox-extensions-declarative/firefox-extensions-declarative";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.git-hooks.follows = "git-hooks";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gremlin-shell = {
      url = "git+https://codeberg.org/bricked/gremlin-shell";
      inputs.flake-parts.follows = "flake-parts";
      inputs.git-hooks.follows = "git-hooks";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit.follows = "git-hooks";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";

      inputs.scenefx = {
        inputs.flake-utils.follows = "flake-utils";
        inputs.systems.follows = "systems";
      };
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "git+https://codeberg.org/bricked/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpaper = {
      url = "https://gitlab.gnome.org/GNOME/gnome-backgrounds/-/raw/600c5348d674a24f12c11902225f2a630fe4594f/backgrounds/blobs-d.svg";
      flake = false;
    };
  };
}
