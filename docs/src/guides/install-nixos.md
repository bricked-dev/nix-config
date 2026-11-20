# Install NixOS

This Nix configuration provides its own installation image. Unlike the official NixOS installer, it bundles the Nix configuration and most of its packages.

```sh
nixos-rebuild build-image --image-variant iso-installer --flake .#installer-homes
```

Burn the installation image onto a flash drive.

On the target system, disable Secure Boot and boot the flash drive. You will automatically be logged in and greeted by Gremlin Shell. This desktop environment lets you test the bundled applications before installing NixOS. The Nix configuration is symlinked to `/etc/nixos`.

Partition the drives with Disko.

> [!WARNING]
> This will erase everything on those drives.

```sh
sudo disko --mode destroy,format,mount --flake /etc/nixos#<host>
```

You will be asked to enter a password for disk encryption.

Install the NixOS configuration.

```sh
sudo nixos-install --no-root-password --flake /etc/nixos#<host>
```

Don't forget to set up user passwords.

```sh
sudo nixos-enter --command "passwd <user>"
```

Finally, reboot into the newly installed NixOS system.
