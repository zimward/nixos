{ config, lib, ... }:
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
      defaults.email = "janick-andresen@web.de";
      certs =
        let
          sub = t: s: "${s}.${t}";
        in
        {
          "zimward.moe" = {
            webroot = "/var/lib/acme/acme-challenge/";
            extraDomainNames = map (sub "zimward.moe") [
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
      virtualHosts."data.zimward.moe" = {
        root = "/nix/persist/static";
        forceSSL = true;
        enableACME = true;
      };
      virtualHosts."zimward.moe" = {
        forceSSL = true;
        enableACME = true;
        # locations."/" = {
        #   extraConfig = "
        #   return 402;
        # ";
        # };
        locations."/" = {
          # proxyPass = "http://localhost:8000/";
          recommendedProxySettings = true;
        };
        extraConfig = "
          access_log /dev/null;
          error_log /dev/null;
        ";
      };
      virtualHosts."search.zimward.moe" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://localhost:8080/";
          recommendedProxySettings = true;
        };
      };
    };
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
