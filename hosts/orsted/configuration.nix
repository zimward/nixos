{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/general.nix
    ../../modules/hardware/poweropt.nix
    ../../modules/net/wifi.nix
  ];

  config = {
    time.timeZone = "Asia/Tokyo";
    virtualisation.libvirtd = {
      enable = true;
      #user mode networking
      allowedBridges = [ "virbr0" ];
    };

    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;

    graphical.kicad.minimal = true;

    networking.hostName = "orsted"; # Define your hostname.
    networking.networkmanager.enable = true;
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      enableCryptodisk = true;
    };
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users.${config.main-user.userName} = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZ4iv3QwB03x5UlteFjPmTymPb29ruuKiMdZLn8jIem mobian@pinephone"
      ];
      extraGroups = [
        "libvirtd"
        "dialout"
      ];
    };
    # only ssh is running with pubkey auth so a firewall would only waste memory
    networking.firewall.enable = false;
    graphical.ime.enable = true;
    graphical.matlab.enable = true;

    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
