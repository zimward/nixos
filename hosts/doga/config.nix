{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.cache-beacon.nixosModules.nix-cache-beacon
    ./hardware-configuration.nix
    ./minecraft.nix
    ./ethercalc
    ./wireguard.nix
    ./nginx.nix
    ./postgres.nix
  ];

  config = {
    device.class = "server";
    mainUser.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILG1gWO9yWvsjgO/L7mWnZGgLsSvlhElW3dafBJW8QRE zimward@arumanfi"
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

    ethernet.share.device = "enp8s0f1";

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
    systemd.services.ethercalc.serviceConfig = {
      StateDirectory = lib.mkForce null;
      WorkingDirectory = lib.mkForce "/nix/persist/system/ethercalc";
      ReadWritePaths = "/nix/persist/system/ethercalc";
    };

    environment.persistence."/nix/persist/system" =
      let
        varDir = d: "/var/lib/${d}";
      in
      lib.mkIf config.tmpfsroot.enable {
        directories = map varDir [
          "samba"
          "userborn"
        ];
      };

    services.nix-cache-beacon = {
      advert = {
        enable = true;
        port = 5000; # Harmonia port
      };

      # Enable local binary cache using discovered caches on the local network
      cache.enable = true;
    };

    # Make Nix aware of our local network cache
    nix.settings.substituters = [ "http://localhost:5028" ];

    services.harmonia.cache.enable = true; # Serve up local Nix store

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
      # harmonia cache
      5000
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
      matchConfig.Name = "enp8s0f0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        DHCPPrefixDelegation = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
