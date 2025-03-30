{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/hardware/tmpfsroot.nix
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
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];
    boot.supportedFilesystems = [ "zfs" ];

    tmpfsroot = {
      enable = true;
      boot = {
        device = "/dev/disk/by-uuid/6028-CED0";
        fsType = "vfat";
      };
      nixstore = {
        device = "/dev/disk/by-uuid/c9f746d0-b1b5-4f52-bc27-869d4a2601ce";
        fsType = "f2fs";
        options = [ "discard" ];
      };
      home = {
        device = "/dev/disk/by-uuid/24b73bb4-2da4-4669-b5e2-f4bc31017e13";
        fsType = "f2fs";
        options = [ "discard" ];
      };
    };

    #import zfs pool on boot
    boot.zfs.extraPools = [ "Pool1_20TB" ];
    boot.zfs.forceImportRoot = false;

    hardware.hddIdle = [
      "sdb"
      "sdc"
      "sdc"
      "sde"
      "sdf"
    ];
    #the server is only running trusted code, so no rist of LPE
    boot.kernelParams = [ "mitigations=off" ];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
