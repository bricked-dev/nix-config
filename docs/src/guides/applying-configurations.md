# Applying Configurations

## NixOS configurations

Applying NixOS configurations on an existing NixOS system is straightforward.

```sh
nixos-rebuild switch --sudo --flake .#<host>
```

## Home Manager configurations

Home Manager configurations are provided for each user listed in the host's `users.nix` module.

```sh
home-manager switch -b backup --flake .#<user>@<host>
```

## NixOS and Home Manager configurations for all users

NixOS configurations with the `-homes` suffix apply both the NixOS configuration and Home Manager configurations for all users listed in the host's `users.nix` module.

```sh
nixos-rebuild switch --sudo --flake .#<host>-homes
```
