{ pkgs, ... }:
{
  services.nginx.virtualHosts."cinny.zimward.moe" = {
    forceSSL = true;
    enableACME = true;
    quic = true;
    locations."/" = {
      root = toString pkgs.cinny;
    };
  };
}
