{ pkgs, ... }:
let
  compressionConf = ''
    gzip "on";
    gzip_types  "text/plain" "text/html" "application/json" "application/xml" "application/wasm";
    gzip_min_length 256;
    zstd "on";
    zstd_comp_level 4;
    zstd_min_length 256;
    zstd_types  "text/plain" "text/html" "application/json" "application/xml" "application/wasm";
  '';
in
{
  services.nginx.virtualHosts."cinny.zimward.moe" = {
    forceSSL = true;
    enableACME = true;
    quic = true;
    locations."/" = {
      root = toString pkgs.cinny;
      extraConfig = ''
        etag on;
        rewrite ^/config.json$ /config.json break;
        rewrite ^/manifest.json$ /manifest.json break;
        rewrite ^/sw.js$ /sw.js break;
        rewrite ^/pdf.worker.min.js$ /pdf.worker.min.js break;
        rewrite ^/public/(.*)$ /public/$1 break;
        rewrite ^/assets/(.*)$ /assets/$1 break;
        rewrite ^(.+)$ /index.html break;
        ${compressionConf}
      '';
    };
  };
  services.nginx.virtualHosts."zimmy.zimward.moe" = {
    forceSSL = true;
    enableACME = true;
    quic = true;
    locations."/" = {
      return = "301 https://cinny.zimward.moe$request_uri";
    };
  };
}
