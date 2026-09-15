{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./filter-chain-siberia.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = {
    device.class = "desktop";
    #gets wiped due to tmpfs
    mainUser.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/nix/persist/system/var/lib/sbctl/";
    };

    environment.persistence."/nix/persist/system" = {
      directories = [
        "/var/lib/sbctl"
        "/root/.ssh"
        "/var/lib/private"
        "/var/lib/userborn"
      ];
    };

    networking.hostName = "kalman";
    ethernet.share.device = "enp39s0";
    ethernet.share.addr = [ "192.168.9.1/24" ];

    virtualisation.libvirtd = {
      enable = true;
      #user mode networking
      allowedBridges = [ "virbr0" ];
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;
    users.users."zimward".extraGroups = [
      "libvirtd"
      "dialout"
    ];

    #usb controller bootloaders
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{product}=="USBasp", ATTR{idProduct}=="05dc", ATTRS{idVendor}=="16c0", GROUP="dialout"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="4348", ATTRS{idProduct}=="55e0", GROUP="dialout"
    '';
    hardware.opentabletdriver.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    # since no services are supposed to run on this machine a firewall would only wase memory
    networking.firewall.enable = false;

    graphical.niri.enable = true;
    programs.niri.package =
      (config.graphical.niri.wrapper.apply {
        settings = {
          binds = {
            "Mod+Y".spawn = [
              #can't use the wrapped package as that is a infrec
              (lib.getExe pkgs.niri)
              "msg"
              "output"
              "DP-3"
              "transform"
              "90"
            ];
            "Mod+Shift+Y".spawn = [
              (lib.getExe pkgs.niri)
              "msg"
              "output"
              "DP-3"
              "transform"
              "normal"
            ];

          };

          workspaces = {
            "com" = {
              open-on-output = "DP-3";
            };
            "games" = {
              open-on-output = "DP-3";
            };
            "browser-l" = {
              open-on-output = "DP-3";
            };
            "browser-r" = {
              open-on-output = "DP-1";
            };
          };

          window-rules = [
            {
              matches = [
                { app-id = "thunderbird"; }
              ];
              open-on-workspace = "com";
            }
            {
              matches = [
                { app-id = "steam"; }
                { app-id = "org.prismlauncher.PrismLauncher"; }
              ];
              open-on-workspace = "games";
            }

            {
              matches = [
                { app-id = "info.mumble.Mumble"; }
              ];
              open-on-workspace = "browser-r";
            }
            {
              matches = [
                { app-id = "FreeTube"; }
              ];
              open-on-workspace = "browser-r";
            }
            {
              matches = [ { app-id = "firefox"; } ];
              open-on-workspace = "browser-l";
            }
          ];

        };
      }).wrapper;
    graphical.obsidian.enable = true;
    graphical.steam.enable = true;
    graphical.deluge.enable = true;
    graphical.minecraft.enable = true;
    specialisation.arbeit.configuration = {
      graphical.steam.enable = lib.mkForce false;
      graphical.deluge.enable = lib.mkForce false;
      graphical.minecraft.enable = lib.mkForce false;
      graphical._freetime = false;
    };
    graphical.ime.enable = true;
    graphical.matlab.enable = true;

    graphical.sync.enable = true;

    misc.llm.enable = true;

    environment.systemPackages = with pkgs; [
      prusa-slicer
      sbctl
      ghidra
      #needed for tpm support to function in virt-manager
      swtpm
    ];

    systemd.network.networks."10-lan" = {
      matchConfig.Name = "enp35s0f*";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        DHCPPrefixDelegation = true;
      };
      linkConfig = {
        MTUBytes = 9000;
      };
    };
    services.resolved.dnsDelegates = {
      local.Delegate = {
        DNS = "192.168.178.1";
        Domains = [
          "ethercalc."
          "fritz.box."
        ];
      };
    };
    environment.etc."/dnssec-trust-anchors.d/local.negative".text = lib.strings.concatLines [
      "home.arpa."
      "10.in-addr.arpa."
      "16.172.in-addr.arpa."
      "17.172.in-addr.arpa."
      "18.172.in-addr.arpa."
      "19.172.in-addr.arpa."
      "20.172.in-addr.arpa."
      "21.172.in-addr.arpa."
      "22.172.in-addr.arpa."
      "23.172.in-addr.arpa."
      "24.172.in-addr.arpa."
      "25.172.in-addr.arpa."
      "26.172.in-addr.arpa."
      "27.172.in-addr.arpa."
      "28.172.in-addr.arpa."
      "29.172.in-addr.arpa."
      "30.172.in-addr.arpa."
      "31.172.in-addr.arpa."
      "170.0.0.192.in-addr.arpa."
      "171.0.0.192.in-addr.arpa."
      "168.192.in-addr.arpa."
      "d.f.ip6.arpa."
      "ipv4only.arpa."
      "resolver.arpa."
      "corp."
      "home."
      "internal."
      "intranet."
      "lan."
      "local."
      "private."
      "test."
      "ethercalc."
      "fritz.box."
    ];

    nix.settings.trusted-public-keys = [
      "doga:y1nuiJdAESNfSTOJz+pna+PoCtNe/cvVUddkD2jAsmI="
    ];

    # nixpkgs.config.rocmSupport = true;

    # services.scx = {
    #   enable = true;
    #   package = pkgs.scx.rustscheds;
    #   scheduler = "scx_lavd";
    #   extraArgs = [ "--autopilot" ];
    # };
  };
}
