{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ../../modules
    ./3dp.nix
  ];
  device.class = "server";
  boot.initrd.systemd.tpm2.enable = false; # rpi dosn't have that module
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "console=ttyS0,115200"
    "console=tty0"
  ];

  mainUser.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

  users.users.${config.mainUser.userName}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOL6wkiD+2gXU8TwEmBld1/2RdBJ4na2FnkYSYIjx4Ua zimward@nixos"
  ];

  networking.hostName = "juliette";
  networking.hostId = "105366CC";

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  networking.useDHCP = lib.mkDefault true;
  networking.wireless = {
    enable = true;
    networks = inputs.secrets.wifi;
  };
  systemd.network.networks."10-wifi" = {
    matchConfig.Name = "wlan0";
    networkConfig = {
      DHCP = true;
      IPv6AccpetRA = true;
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/FEFB-74C3";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
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

  services.btrfs.autoScrub.fileSystems = [ "/nix" ];

  nixpkgs.hostPlatform = {
    system = "aarch64-linux";
  };
  nixpkgs.buildPlatform = {
    system = "aarch64-linux";
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.11";
}
