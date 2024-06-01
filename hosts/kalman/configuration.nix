# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
flake-overlays: {
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../modules/general.nix
    ../../modules/hardware/tmpfsroot.nix
    ../../modules/net/eth_share.nix
  ];
  #gets wiped due to tmpfs
  config.main-user.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

  #enable tmpfs root (currently only changes sops key location)
  config.tmpfsroot.enable = true;

  config.ethernet.share.device = "enp49s0f3u3";

  config.graphical.steam.enable = true;
  config.graphical.deluge.enable = true;

  config = {
    pid-fan-controller.enable = true;
    environment.etc."pid-fan-settings.json".source = ./pid-fan-settings.json;
    nixpkgs.overlays = [] ++ flake-overlays;

    nix.settings.experimental-features = ["nix-command" "flakes"];

    boot.binfmt.emulatedSystems = ["aarch64-linux"];

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    #workaround
    services.logrotate.checkConfig = false;

    networking.hostName = "kalman"; # Define your hostname.
    # networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    #obsidian
    environment.systemPackages = with pkgs; [
      obsidian
    ];
    nixpkgs.config.permittedInsecurePackages = [
      "electron-25.9.0"
    ];

    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    hardware.opentabletdriver.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # List services that you want to enable:

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = false;

    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
