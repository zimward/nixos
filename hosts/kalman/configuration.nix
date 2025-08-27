{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./filter-chain-siberia.nix
    ../../modules
    ../../modules/net/eth_share.nix
  ];

  config = {
    device.class = "desktop";
    #gets wiped due to tmpfs
    mainUser.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

    boot.kernelPackages = pkgs.linuxPackages_latest;
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
      ];
    };

    networking.hostName = "kalman";

    virtualisation.libvirtd = {
      enable = true;
      #user mode networking
      allowedBridges = [ "virbr0" ];
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;
    users.users."zimward".extraGroups = [
      "libvirtd"
      "dialout"
    ];
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{product}=="USBasp", ATTR{idProduct}=="05dc", ATTRS{idVendor}=="16c0", MODE="0666"
    '';
    hardware.opentabletdriver.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    # since no services are supposed to run on this machine a firewall would only wase memory
    networking.firewall.enable = false;

    graphical.niri.enable = true;
    graphical.steam.enable = true;
    graphical.deluge.enable = true;
    graphical.minecraft.enable = true;
    specialisation.arbeit.configuration = {
      graphical.steam.enable = lib.mkForce false;
      graphical.deluge.enable = lib.mkForce false;
      graphical.minecraft.enable = lib.mkForce false;
    };
    graphical.ime.enable = true;

    services.open-webui = {
      # enable = true;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
        WEBUI_AUTH = "False";
      };
    };

    nixpkgs.allowUnfreePackages = [ "open-webui" ];
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "ollama" ''
        HSA_OVERRIDE_GFX_VERSION=10.3.0 ${lib.getExe pkgs.ollama-rocm} $@
      '')
      pkgs.freecad
      pkgs.prusa-slicer
      pkgs.sbctl
    ];

    hm.programs.helix.package = pkgs.symlinkJoin {
      name = "helix";
      paths = [ pkgs.helix ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/hx \
          --set HANDLER "ollama" \
          --set OLLAMA_MODEL "gemma3n:e2b"
      '';
    };
    hm.programs.helix.languages = {
      language-server.gpt = {
        command = lib.getExe pkgs.helix-gpt;
      };
      language = [
        {
          name = "matlab";
          language-servers = [ "gpt" ];
        }
        {
          name = "rust";
          language-servers = [
            "rust-analyzer"
            "gpt"
          ];
        }
      ];
    };

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

    nix.settings.substituters = [
      "http:192.168.0.1:5000"
    ];
    nix.settings.trusted-public-keys = [
      "doga:y1nuiJdAESNfSTOJz+pna+PoCtNe/cvVUddkD2jAsmI="
    ];

    nix.buildMachines = [
      {
        hostName = "doga";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 8;
        speedFactor = 1;
        sshUser = "nixremote";
        sshKey = "/roo/.ssh/id_ed25516";
        supportedFeatures = [
          "kvm"
          "big-parallel"
        ];
      }
    ];
    nix.distributedBuilds = true;

    graphical.matlab.enable = true;

    # services.scx = {
    #   enable = true;
    #   package = pkgs.scx.rustscheds;
    #   scheduler = "scx_lavd";
    #   extraArgs = [ "--autopilot" ];
    # };
  };
}
