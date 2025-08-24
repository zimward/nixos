{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ../../modules
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];
  device.class = "server";

  mainUser.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

  users.users.${config.mainUser.userName}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOL6wkiD+2gXU8TwEmBld1/2RdBJ4na2FnkYSYIjx4Ua zimward@nixos"
  ];

  networking.hostName = "juliette";
  networking.hostId = "105366CC";

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };
  console.enable = false;
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  networking.useNetworkd = lib.mkForce true;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/FEFB-74C3";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-uuid/b59aaaff-7b5e-4630-b7b3-1c86c3f3f283";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd:3"
      ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/b59aaaff-7b5e-4630-b7b3-1c86c3f3f283";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "compress=zstd:6"
      ];
    };
    "/persist" = {
      device = "/dev/disk/by-uuid/b59aaaff-7b5e-4630-b7b3-1c86c3f3f283";
      fsType = "btrfs";
      options = [
        "subvol=persist"
        "compress=zstd:3"
      ];
    };
  };
  nixpkgs.hostPlatform = {
    system = "aarch64-linux";
  };
  system.stateVersion = "25.11";
}
