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
      "kvm-intel"
      "nct6775"
    ];
    boot.extraModulePackages = [ ];
    boot.supportedFilesystems = [ "zfs" ];

    tmpfsroot.impermanence = true;
    sops.age.keyFile = lib.mkForce "/nix/persist/system/var/lib/sops-nix/key.txt";

    #needed for postDeviceCommands
    system.etc.overlay.enable = false;
    boot.initrd.systemd.enable = false;
    boot.initrd.postDeviceCommands = lib.mkBefore ''
      mkdir -p /mnt
      mount ${config.fileSystems."/".device} /mnt

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
        heatSources = [
          {
            name = "cpu";
            wildcardPath = "/sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input";
            pidParams = {
              setPoint = 60;
              P = -5.0e-3;
              I = -2.0e-3;
              D = -6.0e-3;
            };
          }
        ];
        fans = [
          {
            #name = "cpu";
            wildcardPath = "/sys/devices/platform/nct6775.2608/hwmon/hwmon*/pwm2";
            minPwm = 0;
            maxPwm = 255;
            heatPressureSrcs = [ "cpu" ];
          }
        ];
      };
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
