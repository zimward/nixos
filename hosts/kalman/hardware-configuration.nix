{
  config,
  lib,
  modulesPath,
  inputs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/hardware/tmpfsroot.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];
  config = {
    boot.initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = ["dm-snapshot" "dm-cache"];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    tmpfsroot = {
      enable = true;
      home = {
        device = "/dev/disk/by-uuid/047830f0-a9d4-4c1f-b1c7-7af9a2b7337e";
        fsType = "ext4";
      };
      nixstore = {
        device = "/dev/disk/by-uuid/8455ca75-43e5-4a7d-9d0f-96950408f262";
        fsType = "f2fs";
        options = ["discard"];
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
      device = "192.168.0.238:/mnt/nas/nas/mainpc";
      fsType = "nfs";
      options = ["x-systemd.automount" "noauto" "soft" "bg" "timeo=10" "noexec"];
    };

    #fan settings
    pid-fan-controller = {
      enable = true;
      settings = {
        heat_srcs = [
          {
            name = "cpu";
            wildcard_path = "sys/class/hwmon/hwmon2/temp1_input";
            PID_params = {
              set_point = 60;
              P = -0.005;
              I = -0.002;
              D = -0.006;
            };
          }
          {
            name = "gpu";
            wildcard_path = "/sys/class/drm/card*/device/hwmon/hwmon*/temp2_input";
            PID_params = {
              set_point = 60;
              P = -0.005;
              I = -0.002;
              D = -0.006;
            };
          }
        ];
        fans = [
          {
            name = "front intake";
            wildcard_path = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm1";
            min_pwm = 60;
            max_pwm = 255;
            cutoff = true;
            heat_pressure_srcs = ["cpu" "gpu"];
          }
          {
            name = "pump";
            wildcard_path = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm2";
            min_pwm = 100;
            max_pwm = 255;
            heat_pressure_srcs = ["cpu"];
          }
          {
            name = "front intake2";
            wildcard_path = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm4";
            min_pwm = 60;
            max_pwm = 255;
            heat_pressure_srcs = ["cpu" "gpu"];
          }
          {
            wildcard_path = "/sys/class/drm/card*/device/hwmon/hwmon*/pwm1";
            min_pwm = 10;
            max_pwm = 255;
            cutoff = true;
            heat_pressure_srcs = ["gpu"];
          }
        ];
      };
    };

    swapDevices = [];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
