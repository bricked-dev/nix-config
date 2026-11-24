# Using the Binary Cache

This Flake provides a binary cache, courtesy of Cachix and GitHub Actions.

The binary cache is already configured for this Flake. To use it, simply accept adding it as substituter when running a Nix command.

## URL

```
https://bricked.cachix.org
```

## Public key

```
bricked.cachix.org-1:SPpNjrCYzlfisekwWTN7dEUQs+OrirrM92h1ZoEnciY=
```

## Flakes

To use the binary cache in your own Flake, add it to your Flake's hints.

```nix
# flake.nix

{
  nixConfig = {
    extra-substituters = ["https://bricked.cachix.org"];
    extra-trusted-public-keys = ["bricked.cachix.org-1:SPpNjrCYzlfisekwWTN7dEUQs+OrirrM92h1ZoEnciY="];
  };
}
```

## See also

- [NixOS Wiki: Using a binary cache](https://wiki.nixos.org/wiki/Binary_Cache#Using_a_binary_cache)
