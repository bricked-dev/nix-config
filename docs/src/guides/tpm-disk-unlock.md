# TPM Disk Unlock

Encrypted disks can automatically be unlocked during Secure Boot. Enable TPM in the UEFI. For each encrypted partition, set up disk unlock by replacing `<encrypted-partion>` with its identifier, e.g. `nvme0n1p1`, `sda1`.

```sh
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=platform-code+external-code+secure-boot-policy+kernel-config /dev/<encrypted-partition>
```

To prevent unauthorized access to the encrypted disks, TPM disk unlock will stop working if any policy listed after `--tpm-pcrs` changes. To enable TPM disk unlock after it stops working, wipe its slot.

```sh
sudo systemd-cryptenroll --tpm2-device=auto --wipe-slot tpm2 /dev/<encrypted-partition>
```

Now, set up TPM disk unlock again.

## Further Readings

- [`systemd-cryptenroll(1)`](https://www.freedesktop.org/software/systemd/man/251/systemd-cryptenroll.html) man page
