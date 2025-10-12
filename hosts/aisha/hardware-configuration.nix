{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_scsi"
      "sr_mod"
    ];

    boot.kernelParams = [
      "console=tty"
      #not really needed
      "module_blacklist=virtio_gpu"
    ];

    systemd.network.enable = true;
    networking.useNetworkd = true;
    systemd.network.networks."10-wan" = {
      networkConfig.DHCP = "no";
      matchConfig.Name = "enp1*";
      address = [
        "95.217.217.249/32"
        "2a01:4f9:c012:36f5::1/64"
      ];
      routes = [
        {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        }
        { Gateway = "fe80::1"; }
      ];
    };

    tmpfsroot = {
      enable = true;
      boot = {
        device = "/dev/disk/by-uuid/80E8-2ED9";
        fsType = "vfat";
      };
      nixstore = {
        device = "/dev/disk/by-uuid/e6f68287-6f65-423a-8bf9-890692e2e63a";
        fsType = "btrfs";
        options = [
          "discard=async"
          "compress=zstd:6"
        ];
      };
    };

    # networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
