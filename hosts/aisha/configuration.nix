{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ./searx.nix
    ./matrix.nix
    ./mail.nix
    ./git.nix
  ];

  config = {
    device.class = "server";
    main-user.userName = lib.mkForce "aisha";
    main-user.hashedPassword = "$y$j9T$wmstfO.Yhb3p4XyS84lDy/$GDLXO3PNgb4GQsHmPBpixsbke/wzs/fY6x0EOBjK395";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "aisha";
    networking.hostId = "01EF6C8D";

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users.${config.main-user.userName}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOL6wkiD+2gXU8TwEmBld1/2RdBJ4na2FnkYSYIjx4Ua zimward@nixos"
    ];

    # ssl cert
    security.acme = {
      acceptTerms = true;
      defaults.email = "zimward+acme@zimward.moe";
      certs =
        let
          sub = t: s: "${s}.${t}";
        in
        {
          "zimward.moe" = {
            webroot = "/var/lib/acme/acme-challenge/";
            extraDomainNames = map (sub "zimward.moe") [
              "matrix"
              "mx1"
              "search"
            ];
          };
        };
    };
    environment.persistence."/nix/persist/system" = lib.mkIf config.tmpfsroot.enable {
      directories = [ "/var/lib/acme/" ];
    };

    services.nginx = {
      enable = true;
      package = pkgs.nginxQuic;
      virtualHosts."data.zimward.moe" = {
        quic = true;
        root = "/nix/persist/static";
        forceSSL = true;
        enableACME = true;
      };
      virtualHosts."zimward.moe" = {
        forceSSL = true;
        enableACME = true;
        quic = true;
        reuseport = true;
        locations."/" = {
          proxyPass = "http://[::1]:8000/";
          recommendedProxySettings = true;
        };
        # extraConfig = "
        #   access_log /dev/null;
        #   error_log /dev/null;
        # ";
      };
      virtualHosts."search.zimward.moe" = {
        forceSSL = true;
        enableACME = true;
        quic = true;
        locations."/" = {
          proxyPass = "http://localhost:8080/";
          recommendedProxySettings = true;
        };
      };
    };

    #prevent OOM on cache fail
    systemd.services.nix-daemon = {
      serviceConfig = {
        MemoryHigh = "1G";
        MemoryMax = "2.5G";
      };
      environment.TMPDIR = "/nix/tmp";
    };
    systemd.tmpfiles.rules = [
      "d /nix/tmp 1640 root root 1d"
      "d /var/log/nginx 1777 nginx nginx 1d"
    ];

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [
      22
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [
      80
      443
    ];
    networking.firewall.enable = true;

    system.stateVersion = "24.11"; # Did you read the comment?
  };
}
