{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  config = {
    device.class = "server";
    main-user.userName = "aisha";
    main-user.hashedPassword = "$y$j9T$wmstfO.Yhb3p4XyS84lDy/$GDLXO3PNgb4GQsHmPBpixsbke/wzs/fY6x0EOBjK395";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "aisha";
    networking.hostId = "01EF6C8D";

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users.${config.main-user.userName}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg"
    ];

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [
      22
    ];
    networking.firewall.allowedUDPPorts = [
    ];
    networking.firewall.enable = true;

    system.stateVersion = "24.11"; # Did you read the comment?
  };
}
