{
  services.searx = {
    enable = true;
    domain = "search.zimward.moe";
    configureNginx = true;
    configureUwsgi = true;
    uwsgiConfig = {
      disable-logging = true;
      socket = "/run/searx/searx.sock";
      chmod-socket = "660";
    };
    settings = {
      server.secret_key = "6isGu4KiUg90Zth1W7cG5K91TJ7iGUQg";
      server.image_proxy = true;
      server.default_locale = "de";
      search.formats = [
        "html"
        "json"
      ];

      engines = [
        {
          name = "bing";
          disabled = false;
        }
        {
          name = "bing images";
          engine = "bing_images";
          disabled = false;
        }
        {
          name = "startpage";
          disabled = false;
        }
      ];
      default_http_headers = {
        "X-Content-Type-Options" = "nosniff";
        "X-XSS-Protection" = "1; mode=block";
        "X-Download-Options" = "noopen";
        "X-Robots-Tag" = "noindex, nofollow";
        "Referrer-Policy" = "no-referrer";
      };
    };
  };
  services.nginx.virtualHosts."search.zimward.moe" = {
    forceSSL = true;
    enableACME = true;
    quic = true;
    extraConfig = ''
      zstd "on";
      zstd_comp_level 8;
      zstd_min_length 256;
      zstd_types  "text/plain" "text/html" "application/json" "application/xml" "text/css" "text/javascript" "image/svg+xml";
      # disable logging
      access_log /var/log/nginx/searxng;
      error_log /dev/null;
    '';
  };
}
