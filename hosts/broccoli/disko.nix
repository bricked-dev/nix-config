{
  boot.zswap.enable = true;

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-eui.00000000000000000026b76851d999e5";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };

        luks = {
          size = "100%";

          content = {
            type = "luks";
            name = "crypted";
            settings.allowDiscards = true;

            content = {
              type = "btrfs";

              subvolumes = {
                "/" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };

                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };

                "/home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd" "noatime"];
                };

                "/swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = "16G";
                };
              };
            };
          };
        };
      };
    };
  };
}
