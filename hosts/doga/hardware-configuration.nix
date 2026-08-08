{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [
      "nct6775"
    ];
    boot.extraModulePackages = [ ];
    boot.supportedFilesystems = [
      "zfs"
      "btrfs"
    ];

    tmpfsroot.impermanence = true;

    #needed for postDeviceCommands
    system.etc.overlay.enable = false;
    boot.initrd.systemd.services.rollback = {
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      after = [
        "${
          lib.removePrefix "-" (
            lib.strings.replaceString "/" "-" (
              lib.strings.replaceString "-" "\\x2d" config.fileSystems."/".device
            )
          )
        }.device"
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = "yes";
      script = ''
        mkdir -p /mnt
        mount ${config.fileSystems."/".device} -t ${config.fileSystems."/".fsType} /mnt

        btrfs subvolume list -o /mnt/root |
        cut -f9 -d' ' |
        while read subvolume; do
          echo "deleting /$subvolume subvolume..."
          btrfs subvolume delete "/mnt/$subvolume"
        done &&
        echo "deleting /root subvolume..." &&
        btrfs subvolume delete /mnt/root

        echo "restoring clean /root subvolume..."
        btrfs subvolume snapshot /mnt/root-clean /mnt/root
        umount /mnt
      '';
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/bda74b6a-91f2-4dfc-9e55-bce9bf5d9d60";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/bda74b6a-91f2-4dfc-9e55-bce9bf5d9d60";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "compress=zstd"
        "noatime"
      ];
    };
    fileSystems."/nix/persist" = {
      device = "/dev/disk/by-uuid/bda74b6a-91f2-4dfc-9e55-bce9bf5d9d60";
      fsType = "btrfs";
      neededForBoot = true;
      options = [
        "subvol=persist"
        "compress=zstd"
      ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F84C-36B9";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    #import zfs pool on boot
    boot.zfs.extraPools = [ "Pool1_20TB" ];
    boot.zfs.forceImportRoot = false;

    #the server is only running trusted code, so no risk of LPE
    boot.kernelParams = [
      "mitigations=off"
      "ia32_emulation=false"
    ];

    networking.useDHCP = lib.mkDefault true;
    systemd.network.enable = true;
    networking.useNetworkd = true;

    services.pid-fan-controller = {
      enable = true;
      settings = {
        interval = 100;
        heat_srcs = [
          {
            name = "cpu";
            wildcard_path = "/sys/devices/platform/nct6775.2608/hwmon/hwmon*/temp2_input";
            PID_params = {
              set_point = 48;
              P = -5.0e-3;
              I = -2.0e-3;
              D = -6.0e-3;
            };
          }
        ];
        fans = [
          {
            #name = "cpu";
            wildcard_path = "/sys/devices/platform/nct6775.2608/hwmon/hwmon*/pwm2";
            min_pwm = 0;
            max_pwm = 255;
            heat_pressure_srcs = [ "cpu" ];
          }
        ];
      };
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
