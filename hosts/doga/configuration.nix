{
  config,
  lib,
  pkgs,
  ...
}:
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

    ethernet.share.device = "enp0s20u3";

    #zfs auto scrubbing
    services.zfs.autoScrub.enable = true;
    #nfs
    services.nfs.server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      exports = ''
        /mnt/nas/nas/mainpc    192.168.0.0/24(rw,fsid=0,no_subtree_check)
        /mnt/nas/nas/basti     192.168.178.39/24(rw,fsid=0,no_subtree_check)
        /mnt/nas/nas/basti     192.168.178.22/24(rw,fsid=0,no_subtree_check)
      '';
    };

    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          "security" = "user";
        };
        private = {
          path = "/mnt/nas/nas/basti";
          browsable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "basti";
          "force group" = "users";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    users.users.basti = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$Zb4MwzGPklZnR/MBpQ7g01$Q1P7ci7xXFLM7W19ctvojiomdn8WxGmg46KKTP1DzZD";
    };

    users.users.lucy = {
      isNormalUser = true;
      home = "/mnt/nas/nas/lucy";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbg58E2ZZL3Pipvt+ajeAeShOgawJkno4uMW+aJ/cVy"
      ];
    };

    services.logind.powerKeyLongPress = "reboot";

    #dlna media server
    services.minidlna = {
      enable = true;
      openFirewall = true;
      settings = {
        friendly_name = config.networking.hostName;
        media_dir = [
          "/mnt/nas/nas/mainpc/Anime"
          "/mnt/nas/nas/mainpc/Serien"
          "/mnt/nas/nas/mainpc/Filme"
          "/mnt/nas/nas/basti/media"
        ];
        inotify = "yes";
        enable_tivo = "yes";
        wide_links = "yes";
        db_dir = "/nix/persist/system/minidlna/";
        log_level = "warn";
      };
    };

    users.users.minidlna.extraGroups = [ "users" ];

    services.ethercalc.enable = true;

    environment.persistence."/nix/persist/system" =
      let
        varDir = d: "/var/lib/${d}";
      in
      lib.mkIf config.tmpfsroot.enable {
        directories = map varDir [
          "private/ethercalc"
          "samba"
        ];
      };

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [
      22
      111
      2049
      4000
      4001
      4002
      20048
      #ethercalc
      8000
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
    #local intranet interface
    networking.firewall.trustedInterfaces = [ config.ethernet.share.device ];

    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
