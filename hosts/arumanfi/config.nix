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
    ./disko.nix
  ];
  config = {

    device.class = "desktop"; # its a laptop but it doesnt matter
    net.wifi.enable = true;
    mainUser.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

    sops.age.keyFile = lib.mkForce "/nix/sops/age/keys.txt";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    # boot.lanzaboote = {
    #   enable = true;
    #   pkiBundle = "/persist/system/var/lib/sbctl/";
    # };

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
    graphical.kicad = {
      enable = true;
      minimal = true;
    };
    graphical.obsidian.enable = true;

    networking.hostName = "arumenfi";
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
    motd.enable = lib.mkForce false;

    environment.persistence."/persist/system" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/NetworkManager/VPN"
      ];
    };

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
        mount /dev/mapper/root /mnt

        btrfs subvolume list -o /mnt/root |
        cut -f9 -d' ' |
        while read subvolume; do
          echo "deleting /$subvolume subvolume..."
          btrfs subvolume delete "/mnt/$subvolume"
        done &&
        echo "deleting /root subvolume..." &&
        btrfs subvolume delete /mnt/root

        echo "restoring clean /root subvolume..."
        btrfs subvolume snapshot /mnt/root-clean /mnt/root
        umount /mnt
      '';
    };

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = true;

  };
}
