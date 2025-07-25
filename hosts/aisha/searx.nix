{ lib, ... }:
{
  services.searx = {
    enable = true;
    settings = {
      server.port = 8080;
      server.bind_address = "127.0.0.1";
      server.secret_key = "6isGu4KiUg90Zth1W7cG5K91TJ7iGUQg";
      server.base_url = "https://search.zimward.moe";
      server.image_proxy = true;
      server.default_locale = "de";

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
}
