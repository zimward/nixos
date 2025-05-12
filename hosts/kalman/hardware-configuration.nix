{
  config,
  lib,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/hardware/tmpfsroot.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];
  config = {
    boot.initrd.availableKernelModules = [
      "nvme"
      "ahci"
      "xhci_pci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [
      "dm-snapshot"
      "dm-cache"
    ];
    boot.kernelModules = [
      "kvm-amd"
      "nct6775"
    ];
    boot.extraModulePackages = [ ];

    tmpfsroot = {
      enable = true;
      home = {
        device = "/dev/disk/by-uuid/90ef6e31-3665-4d6f-b69c-01c358c68076";
        fsType = "btrfs";
        options = [ "compress=zstd:3" ];
      };
      nixstore = {
        device = "/dev/disk/by-uuid/8455ca75-43e5-4a7d-9d0f-96950408f262";
        fsType = "f2fs";
        options = [ "discard" ];
      };
      boot = {
        device = "/dev/disk/by-uuid/E939-E650";
        fsType = "vfat";
      };
    };

    #crypttab for lvm drives
    environment.etc.crypttab.text = ''
      home_hdd UUID="5bd75570-c441-4509-b21c-144cd13838b5" /nix/persist/keyfiles/home_hdd
      home_ssd UUID="3d67fb6e-d7a8-41a6-9e7b-6fbbe5309f6b" /nix/persist/keyfiles/home_ssd
    '';

    boot.initrd.luks.devices."root" = {
      device = "/dev/disk/by-uuid/a4cb3149-6939-4416-8cdd-0d9bf3a8306f";
      allowDiscards = true;
    };

    #nfs
    fileSystems."/mnt/nas" = {
      device = "192.168.0.1:/mnt/nas/nas/mainpc";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "soft"
        "bg"
        "timeo=10"
        "noexec"
      ];
    };

    #fan settings
    services.pid-fan-controller = {
      enable = true;
      settings = {
        heatSources = [
          {
            name = "cpu";
            wildcardPath = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input";
            pidParams = {
              setPoint = 60;
              P = -5.0e-3;
              I = -2.0e-3;
              D = -6.0e-3;
            };
          }
          {
            name = "gpu";
            wildcardPath = "/sys/class/drm/card*/device/hwmon/hwmon*/temp2_input";
            pidParams = {
              setPoint = 65;
              P = -5.0e-3;
              I = -2.0e-3;
              D = -6.0e-3;
            };
          }
        ];
        fans = [
          {
            #name = "front intake";
            wildcardPath = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm1";
            minPwm = 60;
            maxPwm = 255;
            heatPressureSrcs = [
              "cpu"
              "gpu"
            ];
          }
          {
            #name = "top exhaust";
            wildcardPath = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm4";
            minPwm = 60;
            maxPwm = 255;
            cutoff = true;
            heatPressureSrcs = [
              "cpu"
              "gpu"
            ];
          }
          {
            #name = "back exhaust";
            wildcardPath = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm5";
            minPwm = 60;
            maxPwm = 255;
            cutoff = true;
            heatPressureSrcs = [
              "cpu"
              "gpu"
            ];
          }
          {
            #name = "front intake 2";
            wildcardPath = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm6";
            minPwm = 100;
            maxPwm = 255;
            heatPressureSrcs = [
              "cpu"
              "gpu"
            ];
          }
          {
            #name = "pump";
            wildcardPath = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm2";
            minPwm = 100;
            maxPwm = 255;
            heatPressureSrcs = [ "cpu" ];
          }
          {
            #name = "gpu";
            wildcardPath = "/sys/class/drm/card*/device/hwmon/hwmon*/pwm1";
            minPwm = 10;
            maxPwm = 255;
            cutoff = true;
            heatPressureSrcs = [ "gpu" ];
          }
        ];
      };
    };

    swapDevices = [ ];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
