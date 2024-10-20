{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ../../modules
    ./git.nix
    ./imgserv.nix
  ];
  config = {
    device.class = "server";
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
      hydraURL = "https://arcu.dyndns.org";
      port = 3000;
      notificationSender = "hydra@localhost";
      buildMachinesFiles = [ ];
      useSubstitutes = true;
      minimumDiskFree = 1;
    };

    services.nginx = {
      enable = true;
      virtualHosts."arcu.dyndns.org" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:3000/";
            recommendedProxySettings = true;
          };
          "/static" = {
            proxyPass = "http://localhost:3000";
            recommendedProxySettings = true;
          };
          "/imgserv/" = {
            proxyPass = "http://[::]:8000/";
            recommendedProxySettings = true;
            extraConfig = ''
              proxy_redirect  http://[::]:8000/ /;
              proxy_read_timeout 60s;
            '';
          };
          "/stat" = {
            extraConfig = ''
              root /var/lib/static/;
              autoindex on;
            '';
          };
        };
      };
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "minespeed200@gmail.com";
    };

    systemd.services.hydra-evaluator.environment = {
      GC_DONT_GC = "true";
      TEMPDIR = "/nix/tmp";
    };

    systemd.tmpfiles.rules = [
      "d /tmp 1777 root root 1d"
      "d /nix/tmp 1777 root root 1d"
    ];

    nix.settings.allowed-uris = [
      "github:"
      "git+ssh://git@arcu.dyndns.org:223"
      "git+ssh://arcugit:/"
      "git+ssh://arcugit:"
    ];
    systemd.services.nix-daemon.environment.TEMPDIR = "/nix/tmp";

    systemd.oomd = {
      enable = true;
      enableSystemSlice = true;
    };
    #dont oom sshd
    systemd.services.sshd.serviceConfig.OOMScoreAdjust = -1000;
    system.stateVersion = "24.05";
  };
}
