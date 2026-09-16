{
  pkgs,
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
    ./wireguard.nix
    ./nginx.nix
    ./postgres.nix
    ./network.nix
    ./vms.nix
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

    security.lockKernelModules = lib.mkForce false;
    virtualisation.xen = {
      enable = true;
      boot.params = [
        "loglvl=all"
        "guest_loglvl=all"
        "com1=115200,8n1,0x3f8"
        "console=com1,vga"
        "dom0=pvh"
        "cpuidle"
        "ucode=scan"
      ];
      dom0Resources.maxMemory = 32768;
      dom0Resources.memory = 16384;
    };

    boot.kernelParams = [
      "console=hvc0"
      "earlyprintk=xen"
    ];
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_7_2;

  };
}
