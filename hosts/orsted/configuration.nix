{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  config = {
    device.class = "desktop"; # its a laptop but it doesnt matter
    net.wifi.enable = true;

    sops.age.keyFile = lib.mkForce "/nix/sops/age/keys.txt";

    devel.git.signingkey = "CBF7FA5EF4B58B6859773E3E4CAC61D6A482FCD9";
    environment.sessionVariables.DEFAULT_BROWSER = lib.getExe pkgs.librewolf;
    xdg.mime.defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };

    graphical.niri.enable = true;
    programs.niri.package = lib.mkForce pkgs.niri;
    graphical.kicad = {
      enable = true;
      minimal = true;
    };
    graphical.obsidian.enable = true;

    networking.hostName = "orsted";
    networking.networkmanager.enable = true;

    boot.initrd.checkJournalingFS = lib.mkForce false;
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = false;
      enableCryptodisk = true;
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users.${config.main-user.userName} = {
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
    motd.enable = lib.mkForce false;

    # vpn stuff
    networking.networkmanager = {
      enableStrongSwan = true;
      plugins = [
        pkgs.networkmanager-openconnect
      ];
    };
    services.fprintd.enable = true;

    main-user.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";
    environment.persistence."/nix/persist/system" = {
      directories = [
        "/var/lib/fprint"
        "/etc/NetworkManager/system-connections"
        "/etc/NetworkManager/VPN"
      ];
    };
    # dont update during uni
    system.autoUpgrade.dates = lib.mkForce "19:00";
    #dont auto garbage collect to prevent having to recompile build tools constantly
    nix.gc.dates = lib.mkForce "monthly";

    system.stateVersion = "23.11";
  };
}
