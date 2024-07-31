{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ../../modules/general_server.nix
  ];
  config = {
    #needed to prevent kernel from failing build due to missing module
    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
    boot.supportedFilesystems = lib.mkForce { zfs = false; };

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

    #all services should be open anyways (unless i overlooked something)
    networking.firewall.enable = false;

    services.hydra = {
      enable = true;
      hydraURL = "http://localhost:3000";
      notificationSender = "hydra@localhost";
      buildMachinesFiles = [ ];
      useSubstitutes = true;
      minimumDiskFree = 1;
    };
    systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";

    systemd.tmpfiles.rules = [ "d /tmp 1777 root root 1d" ];

    nix.settings.allowed-uris = [
      "github:"
      "git+ssh://git@arcu.dyndns.org:223"
      "git+ssh://arcugit:/"
      "git+ssh://arcugit:"
    ];

    system.stateVersion = "24.05";
  };
}
