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
    ../../modules/hardware/poweropt.nix
    ../../modules/net/wifi.nix
  ];

  config = {
    device.class = "desktop"; # its a laptop but it doesnt matter
    net.wifi.enable = true;
    time.timeZone = "Asia/Tokyo";

    boot.kernelPackages = pkgs.linuxPackages_latest;

    programs.virt-manager.enable = true;

    # boot.binfmt.emulatedSystems = [ "riscv64-linux" ];
    boot.initrd.checkJournalingFS=false;
     # system.rebuild.enableNg = true;

    #for zoom
    environment.systemPackages = with pkgs; [
      chromium
      warpinator
      freecad
    ];
    graphical.steam.enable = true;
    environment.sessionVariables.DEFAULT_BROWSER = lib.getExe pkgs.librewolf;
    xdg.mime.defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
    graphical.kicad.enable = true;
    graphical.kicad.minimal = true;
    graphical.obsidian.enable = true;

    networking.hostName = "orsted"; # Define your hostname.
    networking.networkmanager.enable = true;
    boot.loader.grub = {
      enable = true;
      device = "nodev";
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

    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
