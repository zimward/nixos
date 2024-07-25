{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # ../../modules/hardware/devices/pine64-pinephonepro/kernel
    ../../modules/general_server.nix
    # ./hardware-configuration.nix
  ];
  config = {
    boot.kernelPackages = pkgs.linuxPackagesFor inputs.ppp-kernel.packages.linuxppp;
    # boot.supportedFilesystems = lib.mkForce ["vfat" "f2fs" "ext4" "tmpfs"];
    boot.loader.generic-extlinux-compatible.enable = true;

    networking.networkmanager.enable = true;

    sdImage.compressImage = false;

    security.apparmor.enable = lib.mkForce false;

    services.openssh.enable = true;

    system.stateVersion = "24.05";
  };
}
