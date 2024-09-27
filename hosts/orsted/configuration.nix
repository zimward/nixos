{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../modules/hardware/poweropt.nix
    ../../modules/net/wifi.nix
  ];

  config = {
    device.class = "desktop"; # its a laptop but it doesnt matter
    time.timeZone = "Asia/Tokyo";

    programs.virt-manager.enable = true;

    graphical.kicad.minimal = true;
    graphical.obsidian.enable = true;

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
    motd.enable = lib.mkForce false;

    # vpn stuff
    networking.networkmanager = {
      enableStrongSwan = true;
      plugins = [
        pkgs.networkmanager-openconnect
      ];
    };
    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
