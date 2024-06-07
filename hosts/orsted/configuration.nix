flake-overlays: {
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../modules/general.nix
    ../../modules/hardware/poweropt.nix
    ../../modules/net/wifi.nix
  ];
  config.graphical.kicad.minimal = true;

  config = {
    nixpkgs.overlays = [] ++ flake-overlays;

    nix.settings.experimental-features = ["nix-command" "flakes"];

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

    users.users.${config.main-user.userName}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZ4iv3QwB03x5UlteFjPmTymPb29ruuKiMdZLn8jIem mobian@pinephone"
    ];
    # only ssh is running with pubkey auth so a firewall would only waste memory
    networking.firewall.enable = false;

    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
