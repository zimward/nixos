{
  disko.devices = {
    disk.nvme = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "384M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "root";
              settings = {
                allowDiscards = true;
              };
              postCreateHook = ''
                MOUNTPOINT="$(mktemp -d)"
                mount "/dev/mapper/root" "$MOUNTPOINT" -o subvol=/
                trap "umount $MOUNTPOINT; rm -fr $MOUNTPOINT" EXIT
                btrfs subvolume snapshot -r "$MOUNTPOINT/rootfs" "$MOUNTPOINT/rootfs-clean"
              '';
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  rootfs = {
                    mountpoint = "/";
                  };
                  persist = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "discard=async"
                    ];
                  };
                  nix = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd:6"
                      "discard=async"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
