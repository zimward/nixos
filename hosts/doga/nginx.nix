{ inputs, ... }:
let
  ip = "[2a01:4f9:c012:36f5:8008:5::2]";
in
{
  security.acme = {
    defaults.email = "zimward+acme@zimward.moe";
    acceptTerms = true;
  };
  environment.persistence."/nix/persist/system" = {
    directories = [ "/var/lib/acme" ];
  };

  services.nginx = {
    enable = true;
    enableReload = true;
    virtualHosts = {
      "doga.zimward.moe" = {
        forceSSL = true;
        enableACME = true;
        listenAddresses = [ ip ];
        locations."/webdav" = {
          basicAuth = {
            zim = inputs.secrets.webdav.zim;
          };
          proxyPass = "http://[::1]:8069";
          recommendedProxySettings = true;
        };
      };
    };
  };

  services.webdav-server-rs = {
    enable = true;
    settings = {
      server.listen = [ "[::1]:8069" ];
      accounts = {
        auth-type = "htpasswd.users";
      };
      htaccess.users = {
        htpasswd = "/nix/persist/webdav/access";
      };
      location = [
        {
          route = [ "/webdav/*path" ];
          directory = "/nix/persist/webdav/files";
          handler = "filesystem";
          methods = [ "webdav-rw" ];
          auth = "false";
        }
      ];
    };
  };
  systemd.services.webdav-server-rs.serviceConfig = {
    ReadWritePaths = [ "/nix/persist/webdav" ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];
}
