{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "xhci_pci"
    "firewire_ohci"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
    "adiantum"
    "chacha_x86_64"
    "nhpoly1305"
    "nhpoly1305_sse2"
  ];
  boot.initrd.kernelModules = [
    "adiantum"
    "chacha_x86_64"
    "nhpoly1305"
    "nhpoly1305_sse2"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ea530a69-5ef7-4481-adad-f51a5c20bf11";
    fsType = "f2fs";
    options = [ "discard" ];
  };

  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/1a109f47-8ea4-4724-ae18-390d6c50320f";
    allowDiscards = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/36c718d5-db0a-4584-9879-f3652fcc6b2c";
    fsType = "ext4";
  };

  swapDevices = [
    # {
    #   device = "/.swapfile";
    #   size = 2 * 1024; # 2GiB
    # }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
