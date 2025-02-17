{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../modules/net/eth_share.nix
  ];

  config = {
    device.class = "desktop";
    #gets wiped due to tmpfs
    main-user.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

    ethernet.share.device = "enp49s0f3u3";

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    #workaround
    services.logrotate.checkConfig = false;

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
    virtualisation.docker.enable = true;
    users.users."zimward".extraGroups = [
      "docker"
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

    specialisation.freizeit.configuration = {
      graphical.steam.enable = true;
      graphical.deluge.enable = true;
      graphical.minecraft.enable = true;
      graphical.ereader.enable = true;
    };
    graphical.irc.enable = true;
    graphical.ime.enable = true;

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

    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
