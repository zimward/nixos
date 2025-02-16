{
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

    swapDevices = [ ];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
