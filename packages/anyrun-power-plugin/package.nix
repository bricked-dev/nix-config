{
  atk,
  cargo,
  glib,
  gtk-layer-shell,
  gtk3,
  lib,
  librsvg,
  makeWrapper,
  pkg-config,
  rustPlatform,
  rustc,
}: let
  inherit (lib) maintainers;

  cargoToml = fromTOML (builtins.readFile ./Cargo.toml);
  pname = cargoToml.package.name;
  inherit (cargoToml.package) version;
in
  rustPlatform.buildRustPackage {
    inherit pname version;

    src = ./.;

    cargoLock = {
      lockFile = ./Cargo.lock;

      # Temporary while packages aren't yet stabilized
      allowBuiltinFetchGit = true;
    };

    strictDeps = true;

    nativeBuildInputs = [
      pkg-config
      makeWrapper
    ];

    buildInputs = [
      glib
      atk
      gtk3
      librsvg
      gtk-layer-shell
    ];

    doCheck = true;
    checkInputs = [
      cargo
      rustc
    ];

    copyLibs = true;

    # CARGO_BUILD_INCREMENTAL = "false";
    RUST_BACKTRACE = "full";

    meta = {
      description = "Power plugin for Anyrun";
      maintainers = [maintainers.bricked];
    };
  }
