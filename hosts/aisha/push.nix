{ config, ... }:
{
  services.mollysocket = {
    enable = true;
    settings = {
      host = "::1";
      vapid_key_file = "vapid_key";
    };
  };
  services.nginx.virtualHosts."molly.zimward.moe" = {
    locations."/" = {
      proxyPass = "http://[${config.services.mollysocket.settings.host}]:${toString config.services.mollysocket.settings.port}";
      recommendedProxySettings = true;
    };
    forceSSL = true;
    quic = true;
    enableACME = true;
  };
}
