{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (builtins) mapAttrs;
  inherit (lib) concatMapStringsSep literalExpression mkMerge mkOption mkOptionDefault nixosSystem singleton types;
  inherit (lib.attrsets) unionOfDisjoint;
  inherit (lib.path) append;
  inherit (lib.strings) escapeNixString escapeNixIdentifier;
  inherit (forestLib) resolveDefault resolveNested transformLib transformModule transformPackage;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;

  forestLib = import ./lib.nix {inherit lib;};
  cfg = config.forest;

  resolveNestedHosts = resolveNested cfg.modules.hostsRoot;
  resolveNestedModules = resolveNested cfg.modules.root;
  resolveNestedUsers = resolveNested cfg.modules.usersRoot;
  resolveDefault' = resolveDefault cfg.root;

  transformLib' = transformLib cfg.lib.args;
  transformTemplate = transformLib cfg.template.args;
  transformModule' = transformModule cfg.modules.args;

  mkRootOption = name: default:
    mkOption {
      defaultText = literalExpression "lib.paths.append config.forest.root ${escapeNixString default}";
      description = "Root directory of ${name}.";
      example = literalExpression "./${default}";
      type = types.path;
    };

  mkArgsOption = name:
    mkOption {
      defaultText = literalExpression "config.forest.args";
      description = "Arguments to bind to ${name}.";
      example = literalExpression "{ inherit inputs self; }";
      type = types.attrs;
    };

  mkNameOption = name: default:
    mkOption {
      inherit default;
      description = "Name of ${name}.";
      example = literalExpression "custom";
      type = types.str;
    };
in {
  options.forest = {
    root = mkOption {
      description = "Root directory of the flake.";
      example = literalExpression "./.";
      type = types.path;
    };

    args = mkOption {
      description = "Arguments to bind.";
      example = literalExpression "{ inherit inputs self; }";
      type = types.attrs;
    };

    # Outputs
    lib = {
      args = mkArgsOption "the lib";
      root = mkRootOption "the lib" "modules";
      name = mkNameOption "the lib" "lib";
    };

    modules = {
      args = mkArgsOption "the modules";

      # Roots
      root = mkRootOption "the modules" "modules";
      usersRoot = mkRootOption "user modules" "users";
      hostsRoot = mkRootOption "host modules" "hosts";

      # Names
      homeManagerName = mkNameOption "Home Manager modules" "home";
      nixosName = mkNameOption "NixOS modules" "nixos";
      flakePartName = mkNameOption "Flake Part modules" "part";
    };

    templates = {
      args = mkArgsOption "the templates";
      root = mkRootOption "the templates" "templates";
      name = mkNameOption "the template" "template";
    };
  };

  config = {
    forest = {
      lib = {
        args = mkOptionDefault (unionOfDisjoint cfg.args {inherit lib;});
        root = mkOptionDefault (append cfg.root "modules");
      };

      templates = {
        args = mkOptionDefault cfg.args;
        root = mkOptionDefault (append cfg.root "templates");
      };

      modules = {
        args = mkOptionDefault cfg.args;
        root = mkOptionDefault (append cfg.root "modules");
        usersRoot = mkOptionDefault (append cfg.root "users");
        hostsRoot = mkOptionDefault (append cfg.root "hosts");
      };
    };

    flake = {
      lib =
        unionOfDisjoint (resolveDefault' cfg.lib.name) (resolveNested cfg.lib.root cfg.lib.name)
        |> mapAttrs (_name: transformLib');

      templates =
        unionOfDisjoint (resolveDefault' cfg.template.name) (resolveNested cfg.template.root cfg.template.name)
        |> mapAttrs (_name: transformTemplate);

      # Modules
      flakeModules =
        unionOfDisjoint (resolveDefault' cfg.modules.flakePartsName) (resolveNestedModules cfg.modules.flakePartsName)
        |> mapAttrs (_name: transformModule' "flake");

      homeModules =
        unionOfDisjoint (resolveDefault' cfg.modules.homeManagerName) (resolveNestedModules cfg.modules.homeManagerName)
        |> mapAttrs (_name: transformModule' "homeManager");

      nixosModules =
        unionOfDisjoint (resolveDefault' cfg.modules.nixosName) (resolveNestedModules cfg.modules.nixosName)
        |> mapAttrs (_name: transformModule' "nixos");
    };

    perSystem = {
      config,
      pkgs,
      system,
      ...
    }: let
      cfg' = config.forest;

      resolveNestedPackages = resolveNested cfg'.packages.root;
      transformPackage' = transformPackage cfg'.pkgs cfg'.packages.args;
    in {
      options.forest = {
        pkgs = mkOption {
          default = pkgs;
          description = "Nixpkgs instance.";
          example = literalExpression "pkgs";
          type = types.pkgs;
        };

        packages = {
          args = mkArgsOption "the packages";
          root = mkRootOption "the packages" "packages";

          # Names
          appsName = mkNameOption "the apps" "app";
          checksName = mkNameOption "the checks" "check";
          devShellsName = mkNameOption "the dev shells" "devShell";
          legacyPackagesName = mkNameOption "the legacyPackages" "legacyPackage";
          packagesName = mkNameOption "the packages" "package";
        };
      };

      config = {
        forest.packages = {
          args = mkOptionDefault cfg.args;
          root = mkOptionDefault (append cfg.root "packages");
        };

        apps =
          unionOfDisjoint (resolveDefault' cfg'.packages.appsName) (resolveNestedPackages cfg'.packages.appsName)
          |> mapAttrs (_name: transformPackage');

        checks =
          unionOfDisjoint (resolveDefault' cfg'.packages.checksName) (resolveNestedPackages cfg'.packages.checksName)
          |> mapAttrs (_name: transformPackage');

        devShells =
          unionOfDisjoint (resolveDefault' cfg'.packages.devShellsName) (resolveNestedPackages cfg'.packages.devShellsName)
          |> mapAttrs (_name: transformPackage');

        legacyPackages = mkMerge [
          (unionOfDisjoint (resolveDefault' cfg'.packages.legacyPackagesName) (resolveNestedPackages cfg'.packages.legacyPackagesName)
            |> mapAttrs (_name: transformPackage'))

          {
            homeConfigurations =
              resolveNestedUsers cfg.modules.homeManagerName
              |> mapAttrs (_name: path:
                homeManagerConfiguration {
                  inherit (cfg') pkgs;
                  extraSpecialArgs = cfg.modules.args;

                  modules = [path];
                });

            nixosConfigurations =
              resolveNestedHosts cfg.modules.nixosName
              |> mapAttrs (_name: path:
                nixosSystem {
                  inherit system;
                  specialArgs = cfg.modules.args;

                  modules = [path];
                });
          }
        ];

        packages =
          unionOfDisjoint (resolveDefault' cfg'.packages.packagesName) (resolveNestedPackages cfg'.packages.packagesName)
          |> mapAttrs (_name: transformPackage');
      };
    };
  };
}
