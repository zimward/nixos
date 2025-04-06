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

    boot.kernelPackages = pkgs.linuxPackages_latest;

    environment.systemPackages = with pkgs; [
      warpinator
    ];
    environment.sessionVariables.DEFAULT_BROWSER = lib.getExe pkgs.librewolf;
    xdg.mime.defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };

    graphical.niri.enable = true;
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
      device = "/dev/sda";
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZ4iv3QwB03x5UlteFjPmTymPb29ruuKiMdZLn8jIem mobian@pinephone"
      ];
      extraGroups = [
        "libvirtd"
        "dialout"
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
    #dont update during uni
    system.autoUpgrade.dates = lib.mkForce "19:00";
    #dont auto garbage collect to prevent having to recompile build tools constantly
    nix.gc.dates = lib.mkForce "monthly";

    system.stateVersion = "23.11";
  };
}
