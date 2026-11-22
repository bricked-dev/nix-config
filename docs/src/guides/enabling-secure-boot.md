# Enabling Secure Boot

Lanzaboote will automatically generate Secure Boot keys when the system is first run. Launch the UEFI to [enter Secure Boot Setup Mode]. Boot the sytem so Lanzaboote can automatically enroll the Secure Boot keys. Launch the UEFI again and enable Secure Boot. Running `bootctl status` should now log `Secure Boot: enabled`.

[Enter Secure Boot Setup Mode]: https://nix-community.github.io/lanzaboote/getting-started/enable-secure-boot.html#enter-secure-boot-setup-mode

## See also

- [Lanzaboote documentation](https://nix-community.github.io/lanzaboote/)
