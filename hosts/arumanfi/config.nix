{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    ./disko.nix
  ];
  config = {
    networking.networkmanager.ensureProfiles.profiles = {
      "39C3" = {
        connection = {
          id = "39C3";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "39C3";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-eap";
        };
        "802-1x" = {
          anonymous-identity = "39C3";
          eap = "ttls;";
          identity = "39C3";
          password = "39C3";
          phase2-auth = "pap";
          altsubject-matches = "DNS:radius.c3noc.net";
          ca-cert = "${builtins.fetchurl {
            url = "https://letsencrypt.org/certs/isrgrootx1.pem";
            sha256 = "sha256:1la36n2f31j9s03v847ig6ny9lr875q3g7smnq33dcsmf2i5gd92";
          }}";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
      };
    };

    device.class = "desktop"; # its a laptop but it doesnt matter
    # net.wifi.enable = true;
    mainUser.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

    tmpfsroot.impermanence = true;

    services.fwupd.enable = true;

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.memtest86.enable = true;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/persist/system/var/lib/sbctl/";
    };

    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
    };

    environment.sessionVariables.DEFAULT_BROWSER = lib.getExe pkgs.librewolf;
    xdg.mime.defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };

    graphical.niri.enable = true;
    programs.niri.package =
      (config.graphical.niri.wrapper.apply {
        settings.input.keyboard.xkb = {
          layout = "de(dvorak)";
          options = "caps:escape";
        };
      }).wrapper;
    graphical.locker.enable = true;
    graphical.kicad = {
      enable = true;
      minimal = true;
    };
    graphical.obsidian.enable = true;
    graphical.minecraft.enable = true;
    graphical.steam.enable = true;

    networking.hostName = "arumanfi";
    networking.useDHCP = lib.mkDefault true;
    networking.networkmanager.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users.${config.mainUser.userName} = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg"
      ];
      extraGroups = [
        "libvirtd"
        "dialout"
        "networkmanager"
      ];
    };
    # only ssh is running with pubkey auth so a firewall would only waste memory
    networking.firewall.enable = false;
    graphical.ime.enable = true;
    graphical.matlab.enable = true;
    environment.systemPackages = with pkgs; [
      freecad-wayland
    ];

    motd.enable = lib.mkForce false;

    boot.kernelParams = [
      #switch to Xe driver
      "xe.force_probe=7d55"
    ];
    #disable intel management engine due to HAP bit
    boot.blacklistedKernelModules = [
      "mei"
      "mei_me"
      "i915"
    ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
      ];
    };
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    hardware.bluetooth.enable = true;

    services.auto-cpufreq = {
      enable = true;
      settings = {
        charger = {
          turbo = "auto";
          energy_performance_preference = "balance_performance";
        };
        battery = {
          turbo = "never";
          energy_performance_preference = "power";
        };
      };
    };

    environment.persistence."/persist/system" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/NetworkManager/VPN"
        "/var/lib/sbctl"
        "/root/.ssh"
      ];
    };
    environment.persistence."/persist/home" = {
      #private dirs
      directories =
        (map
          (d: {
            directory = "/home/${config.mainUser.userName}/${d}";
            user = config.mainUser.userName;
            group = "users";
            mode = "0700";
          })
          [
            ".ssh"
            ".gnupg"
          ]
        )
        ++
          #normal ones, group readable
          map
            (d: {
              directory = "/home/${config.mainUser.userName}/${d}";
              user = config.mainUser.userName;
              group = "users";
            })
            [
              "Downloads"
              "gits"
              "Dokumente"
              ".librewolf"
              ".thunderbird"
              ".cache" # change this later once permissions have been figured out properly
              ".config" # same as above
              ".local" # ""
              ".steam"
            ];
    };
    sops.age.keyFile = lib.mkForce "/persist/age/key";
    #dont auto garbage collect to prevent having to recompile build tools constantly
    nix.gc.dates = lib.mkForce "monthly";

    #clean root on boot for impermanence
    boot.initrd.systemd.services.rollback = {
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      after = [ "systemd-cryptsetup@root.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = "yes";
      script = ''
        mkdir -p /mnt
        mount /dev/mapper/root /mnt -o subvol=/

        btrfs subvolume list -o /mnt/rootfs |
        cut -f9 -d' ' |
        while read subvolume; do
          echo "deleting /$subvolume subvolume..."
          btrfs subvolume delete "/mnt/$subvolume"
        done &&
        echo "deleting /rootfs subvolume..." &&
        btrfs subvolume delete /mnt/rootfs

        echo "restoring clean /root subvolume..."
        btrfs subvolume snapshot /mnt/rootfs-clean /mnt/rootfs
        umount /mnt
      '';
    };

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = true;
    hardware.enableRedistributableFirmware = true;
  };
}
