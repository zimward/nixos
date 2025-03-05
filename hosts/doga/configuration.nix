{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  config = {
    device.class = "server";
    main-user.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";
    updateScript.cfgRef = "shilagit:git/nixos";
    #zfs key location
    sops.secrets.naskey = {
      "format" = "binary";
      sopsFile = ../../secrets/naskey;
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.systemd-boot.memtest86.enable = true;

    networking.hostName = "doga";
    networking.hostId = "bc365a3a";
    networking.networkmanager.enable = true;

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users.${config.main-user.userName}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg modsog@mainpc"
    ];

    ethernet.share.device = "enp49s0f3u3";

    #zfs auto scrubbing
    services.zfs.autoScrub.enable = true;
    #nfs
    services.nfs.server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      exports = ''
        /mnt/nas/nas/mainpc    192.168.0.20(rw,fsid=0,no_subtree_check)
      '';
    };

    services.logind.powerKeyLongPress = "reboot";

    #dlna media server
    services.minidlna = {
      enable = true;
      openFirewall = true;
      settings = {
        friendly_name = config.networking.hostName;
        media_dir = [
          "V,/mnt/nas/nas/mainpc/Anime"
        ];
        log_level = "error";
      };
    };

    users.users.minidlna.extraGroups = [ "users" ];

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [
      22
      111
      2049
      4000
      4001
      4002
      20048
    ];
    networking.firewall.allowedUDPPorts = [
      2049
      111
      4000
      4001
      4002
      20048
    ];
    networking.firewall.enable = true;

    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
