{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/hardware/tmpfsroot.nix
  ];

  config = {

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_scsi"
      "sr_mod"
    ];

    # boot.initrd.kernelModules = [ "virtio_gpu" ];
    boot.kernelParams = [ "console=tty" ];

    systemd.network.enable = true;
    networking.useNetworkd = true;
    systemd.network.networks."10-wan" = {
      networkConfig.DHCP = "ipv4";
      matchConfig.Name = "enp1";
      address = [
        "95.217.217.249"
        "2a01:4f9:c012:36f5::1/64"
      ];
      routes = [
        {
          Gateway = "fe80::1";
        }
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
          "discard"
          "compress=zstd:6"
        ];
      };
    };

    # networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
