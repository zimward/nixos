{ config, ... }:
let
  fqdn = "push.zimward.moe";
in
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://${fqdn}";
      listen-unix = "/run/ntfy-sh/ntfy.sock";
      listen-unix-mode = 0660;
      behind-proxy = true;
      attachment-total-size-limit = "100M";
      enable-login = true;
      enable-signup = true;
      auth-default-access = "deny-all";
      cache-file = "/nix/persist/ntfy/cache.db";
      auth-file = "/nix/persist/ntfy/auth.db";
    };
  };
  systemd.services.ntfy-sh.serviceConfig = {
    RuntimeDirectory = "ntfy-sh";
    ReadWritePaths = "/nix/persist/ntfy";
  };
  users.users."nginx".extraGroups = [ config.services.ntfy-sh.group ];
  services.nginx.virtualHosts.${fqdn} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://unix:${config.services.ntfy-sh.settings.listen-unix}";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";

          access_log /dev/null;
          error_log /dev/null;
        '';
      };
    };
  };
}
