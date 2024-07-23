{
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ../../modules/general_server.nix
  ];
  config = {
    #needed to prevent kernel from failing build due to missing module
    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // {allowMissing = true;});
      })
    ];
    boot.supportedFilesystems = lib.mkForce {
      zfs = false;
    };

    sdImage.compressImage = false;

    networking.hostName = "shila";
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    security.apparmor.enable = lib.mkForce false;

    users.users.${config.main-user.userName}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZ4iv3QwB03x5UlteFjPmTymPb29ruuKiMdZLn8jIem mobian@pinephone"
    ];
    # only ssh is running with pubkey auth so a firewall would only waste memory
    networking.firewall.enable = false;

    system.stateVersion = "24.05";
  };
}
