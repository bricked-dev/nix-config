{
  # Test whether `?dir` parameters break relative flake inputs by running
  # `nix repl git+https://codeberg.org/bricked/nix-config/?ref=test-nested-flake&dir=test-nested-flake --no-write-lock-file`
  # and confirming that nix-config exists.

  outputs = inputs: {
    inherit (inputs) nix-config;
  };

  inputs.nix-config.url = "..";
}
