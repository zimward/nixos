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

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "laptop"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    enableCryptodisk = true;
  };
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

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
