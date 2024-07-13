{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];
  config = {
    boot.supportedFilesystems = lib.mkForce ["vfat" "f2fs" "ext4" "tmpfs"];
    sdImage.compressImage = false;

    services.openssh.enable = true;

    system.stateVersion = "24.05";
    nixpkgs.hostPlatform = "aarch64-linux";
  };
}
