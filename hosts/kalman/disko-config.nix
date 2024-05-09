{disks , ...}:
{
  disko.devices = {
    disk = {
      osdrive = {
        type = "disk";
        device = "/dev/disk/by-id/"
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                ];
              };
            };
            # only /nix should reside here
            nixluks = {
              size = "100%";
              content = {
                type = "luks";
                name = "nix";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "f2fs";
                  mountpoint = "/nix";
                  mountOptions = [
                    "defaults";
                  ];
                };
              };
            };
            
          };
        };
      };
      home_hdd = {
        type = "disk";
        device = "/dev/disk/by-id/";
        content = {
          type = "luks";
          settings = {
            keyfile = "/run/secret/<keyfile>";
          };
          content = {
            type = "lvm_pv";
            vg = "home_vg";
          };
        };
      };
      home_ssd = {
        type = "disk";
        device = "/dev/disk/by-id/";
        content = {
          type = "luks";
          settings = {
            keyfile = "/run/secret/<keyfile>";
          };
          content = {
            type = "lvm_pv";
            vg = "cache";
          };
        };
      };
    lvm_vg = {
      home_vg = {
        type = "lvm_vg";
        lvs = {
          home = {
            size="100%";
            lvm_type = "linear";
            content = {
              type="filesystem";
              format="ext4";
              mountpoint="/home";
              mountOptions=[
                "defaults"
              ];
            };
          };
        };
      };
      cache = {
        type = "lvm_vg";
        lvs = {
          home_cache = {
            size="100%";
            lvm_type="cache";
            extraOptions = [
              "--cachevol" "cache" "vg/home_vg"
            ];
          };
        };
      };
    };
    };
  };
}
