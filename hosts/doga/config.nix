{
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./minecraft.nix
    ./ethercalc
    ./wireguard.nix
  ];

  config = {
    device.class = "server";
    mainUser.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";
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

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users.${config.mainUser.userName}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg" # workstation
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOL6wkiD+2gXU8TwEmBld1/2RdBJ4na2FnkYSYIjx4Ua" # T400
    ];

    users.users.nixremote = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPUiddXuQtZL/cr+luVOh+GKQVWS/y4jPjdVrBLYnTQb root@kalman"
      ];
      group = "users";
    };
    nix.settings.trusted-users = [
      "nixremote"
      "@builders"
      "zimward"
    ];

    ethernet.share.device = "enp2s0f1";

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

    services.logind.settings.Login.HandlePowerKeyLongPress = "reboot";

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

    services.ethercalc2.enable = true;
    systemd.services.ethercalc2.serviceConfig = {
      StateDirectory = lib.mkForce null;
      WorkingDirectory = lib.mkForce "/nix/persist/system/ethercalc";
      ReadWritePaths = "/nix/persist/system/ethercalc";
    };

    services.home-assistant = {
      enable = true;
      configDir = "/nix/persist/system/homeassistant";
      configWritable = true;
      openFirewall = true;
      extraComponents = [
        "analytics"
        "default_config"
        "esphome"
        "my"
        "met"
        "wled"
        "fritz"
        "fritzbox"
        "fritzbox_callmonitor"
      ];
      config = {
        homeassistant = {
          name = "DB Service Center";
          unit_system = "metric";
          latitude = 52.52;
          longitude = 13.45;
          time_zone = "Europe/Berlin";
        };
        http = { };
      };
    };

    environment.persistence."/nix/persist/system" =
      let
        varDir = d: "/var/lib/${d}";
      in
      lib.mkIf config.tmpfsroot.enable {
        directories = map varDir [
          "samba"
        ];
      };

    services.nix-serve = {
      enable = true;
      openFirewall = true;
      secretKeyFile = "/nix/persist/store-keys/secret-key-file";
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

    #public interface with ipv6 config
    systemd.network.networks."10-public" = {
      matchConfig.Name = "enp2s0f0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        DHCPPrefixDelegation = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
