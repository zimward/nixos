{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./searx.nix
    ./matrix.nix
    ./mail.nix
    ./git.nix
  ];

  config = {
    device.class = "server";
    mainUser.userName = lib.mkForce "aisha";
    mainUser.hashedPassword = "$y$j9T$wmstfO.Yhb3p4XyS84lDy/$GDLXO3PNgb4GQsHmPBpixsbke/wzs/fY6x0EOBjK395";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    #fails sometimes due to nginx permissions
    systemd.services.logrotate-checkconf.enable = false;

    networking.hostName = "aisha";
    networking.hostId = "01EF6C8D";

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users.${config.mainUser.userName}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOL6wkiD+2gXU8TwEmBld1/2RdBJ4na2FnkYSYIjx4Ua zimward@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILG1gWO9yWvsjgO/L7mWnZGgLsSvlhElW3dafBJW8QRE zimward@arumanfi"
    ];

    users.users.shared = {
      isNormalUser = true;
      home = "/nix/persist/users/shared";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOL6wkiD+2gXU8TwEmBld1/2RdBJ4na2FnkYSYIjx4Ua zimward@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSveEMHezj5v/JPfl9ES+00Z+lT4y4+m80ItAdXXSIV" # friend
      ];
    };

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
            ];
          };
        };
    };
    environment.persistence."/nix/persist/system" = lib.mkIf config.tmpfsroot.enable {
      directories = [ "/var/lib/acme/" ];
    };

    services.nginx.additionalModules = [ pkgs.nginxModules.zstd ];
    services.nginx = {
      enable = true;
      package = pkgs.nginx;
      #add headers to make browsers actually use quic
      commonHttpConfig = ''
        add_header Alt-Svc  'h3=":443"; ma=3600, h2=":443"; ma=3600';
        add_header Alt-Svc  'h2=":443"; ma=2592000; persist=1';
        add_header Alt-Svc  'h2=":443"; ma=2592000;';
        ssl_early_data on;
      '';
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
      "d /nix/tmp 1777 root root 1d"
      "d /var/log/nginx 1640 nginx nginx 1d"
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
