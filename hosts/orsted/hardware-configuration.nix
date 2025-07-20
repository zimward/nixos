{
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

  tmpfsroot.impermanence = true;

  #needed for postDeviceCommands
  system.etc.overlay.enable = false;
  boot.initrd.systemd.enable = false;
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    mkdir -p /mnt
    mount /dev/mapper/root /mnt

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
    device = "/dev/disk/by-uuid/9be3bce1-661b-4b41-9388-07ea5422cb55";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
    ];
  };

  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/841cd5c7-0685-40b2-a395-f231e859211a";

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/9be3bce1-661b-4b41-9388-07ea5422cb55";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix/persist" = {
    device = "/dev/disk/by-uuid/9be3bce1-661b-4b41-9388-07ea5422cb55";
    fsType = "btrfs";
    options = [
      "subvol=persist"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9be3bce1-661b-4b41-9388-07ea5422cb55";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9CAE-81DE";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "defaults"
      "mode=755"
    ];
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
