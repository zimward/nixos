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
    ../../modules/hardware/poweropt.nix
    ../../modules/net/wifi.nix
  ];

  nixpkgs.overlays = [] ++ flake-overlays;

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    enableCryptodisk = true;
    entryOptions = "--class submenu";
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "laptop"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #obsidian
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
    ];
  environment.systemPackages = with pkgs; [
    obsidian
  ];
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  #sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  #allow user processes to run with realitme scheduling
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    #may need to enable alsa if some applications need it
    alsa.enable = false;
    alsa.support32Bit = false;
    pulse.enable = true;
  };

  # opengl 32bit support
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users.${config.main-user.userName}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZ4iv3QwB03x5UlteFjPmTymPb29ruuKiMdZLn8jIem mobian@pinephone"
  ];

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
}
