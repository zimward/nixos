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
      directories = [ "/var/lib/sbctl" ];
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
    graphical.ereader.enable = true;
    specialisation.arbeit.configuration = {
      graphical.steam.enable = lib.mkForce false;
      graphical.deluge.enable = lib.mkForce false;
      graphical.minecraft.enable = lib.mkForce false;
      graphical.ereader.enable = lib.mkForce false;
    };
    graphical.ime.enable = true;

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "ollama" ''
        HSA_OVERRIDE_GFX_VERSION=10.3.0 ${lib.getExe pkgs.ollama-rocm} $@
      '')
      pkgs.freecad
      pkgs.prusa-slicer
      pkgs.sbctl
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

    nix.settings.substituters = [
      "http:192.168.0.1:5000"
    ];
    nix.settings.trusted-public-keys = [
      "doga:y1nuiJdAESNfSTOJz+pna+PoCtNe/cvVUddkD2jAsmI="
    ];

    # nix.buildMachines = [
    #   {
    #     hostName = "shila";
    #     system = "aarch64-linux";
    #     protocol = "ssh-ng";
    #     maxJobs = 4;
    #     speedFactor = 1;
    #     supportedFeatures = [ "big-parallel" ];
    #   }
    # ];
    # nix.distributedBuilds = true;
    # nix.extraOptions = ''
    #   builders-use-substitutes=true
    # '';

    graphical.matlab.enable = true;

    services.scx = {
      enable = true;
      package = pkgs.scx.rustscheds;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopilot" ];
    };
  };
}
