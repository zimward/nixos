{
  lib,
  pkgs,
  ...
}:
{
  config = {
    boot.initrd.kernelModules = [
      "dm-snapshot"
      "dm-cache"
    ];
    boot.kernelModules = [
      "kvm-amd"
      "nct6775"
    ];
    tmpfsroot = {
      enable = true;
      home = {
        device = "/dev/disk/by-uuid/90ef6e31-3665-4d6f-b69c-01c358c68076";
        fsType = "btrfs";
        options = [ "compress=zstd:3" ];
      };
      nixstore = {
        device = "/dev/disk/by-uuid/31ecb0fe-1c05-48e8-b9e3-0554e8f14ef0";
        fsType = "xfs";
        options = [ "discard" ];
      };
      boot = {
        device = "/dev/disk/by-uuid/C8C3-A169";
        fsType = "vfat";
      };
    };

    #crypttab for lvm drives
    environment.etc.crypttab.text = ''
      home_hdd UUID="5bd75570-c441-4509-b21c-144cd13838b5" /nix/persist/keyfiles/home_hdd
      home_ssd UUID="3d67fb6e-d7a8-41a6-9e7b-6fbbe5309f6b" /nix/persist/keyfiles/home_ssd
    '';

    boot.initrd.luks.devices."root" = {
      device = "/dev/disk/by-uuid/63b531df-fb4a-4c14-8668-8faa34cda107";
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
        heat_srcs = [
          {
            name = "cpu";
            wildcard_path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input";
            PID_params = {
              set_point = 60;
              P = -0.005;
              I = -0.05;
              D = -0.01;
            };
          }
          {
            name = "gpu";
            wildcard_path = "/sys/class/drm/card*/device/hwmon/hwmon*/temp2_input";
            PID_params = {
              set_point = 65;
              P = -0.005;
              I = -0.05;
              D = -0.01;
            };
          }
        ];
        fans = [
          {
            #name = "front intake";
            wildcard_path = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm1";
            min_pwm = 60;
            max_pwm = 255;
            heat_pressure_srcs = [
              "cpu"
              "gpu"
            ];
          }
          {
            #name = "top exhaust";
            wildcard_path = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm4";
            min_pwm = 60;
            max_pwm = 255;
            cutoff = true;
            heat_pressure_srcs = [
              "cpu"
              "gpu"
            ];
          }
          {
            #name = "back exhaust";
            wildcard_path = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm5";
            min_pwm = 60;
            max_pwm = 255;
            cutoff = true;
            heat_pressure_srcs = [
              "cpu"
              "gpu"
            ];
          }
          {
            #name = "front intake 2";
            wildcard_path = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm6";
            min_pwm = 100;
            max_pwm = 255;
            heat_pressure_srcs = [
              "cpu"
              "gpu"
            ];
          }
          {
            #name = "pump";
            wildcard_path = "/sys/devices/platform/nct6775.2592/hwmon/hwmon*/pwm2";
            min_pwm = 100;
            max_pwm = 255;
            heat_pressure_srcs = [ "cpu" ];
          }
          {
            #name = "gpu";
            wildcard_path = "/sys/class/drm/card*/device/hwmon/hwmon*/pwm1";
            min_pwm = 10;
            max_pwm = 255;
            cutoff = true;
            heat_pressure_srcs = [ "gpu" ];
          }
        ];
      };
    };

    networking.useDHCP = lib.mkDefault true;
    environment.etc."machine-id".text = "d938ee7267cc490cbaaf0b8193cd754b";
    hardware.facter = {
      enable = true;
      reportPath = ./report.json;
    };
  };
}
