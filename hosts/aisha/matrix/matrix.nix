{
  pkgs,
  config,
  lib,
  secrets,
  ...
}:
let
  cfg = config.services.matrix;
  unixMatrix = "/run/matrix-synapse/matrix-synapse.sock";
  proxyConf = {
    proxyPass = "http://unix:${unixMatrix}";
    recommendedProxySettings = true;
  };
  compressionConf = ''
    gzip "on";
    gzip_types  "text/plain" "text/html" "application/json" "application/xml";
    gzip_proxied "no-cache" "no-store" "private" "expired" "auth";
    gzip_min_length 256;
    zstd "on";
    zstd_comp_level 8;
    zstd_min_length 256;
    zstd_types  "text/plain" "text/html" "application/json" "application/xml";
  '';

  port = 8448;
  url = "https://${cfg.fqdn}";
  serverConfig."m.server" = "${cfg.fqdn}:${toString port}";
  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  services.matrix.clientConfig = {
    "m.homeserver".base_url = url;
  };

  services.postgresql.ensureUsers = [
    {
      name = "matrix-synapse";
    }
  ];

  services.matrix-synapse = {
    enable = true;
    enableRegistrationScript = true;
    dataDir = "/nix/persist/system/matrix-synapse/";
    settings = {
      registration_shared_secret = secrets.matrix.registration;
      server_name = "zimward.moe";
      public_baseurl = "https://zimward.moe";
      max_upload_size = "100M";
      listeners = [
        {
          port = 8008;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          resources = [
            {
              names = [
                "client"
              ];
              compress = false;
            }
          ];
        }
        {
          path = unixMatrix;
          type = "http";
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = false;
            }
          ];
        }
      ];
      ip_range_whitelist = [
        "127.0.0.42/32"
        "95.217.217.249/32"
        "2a01:4f9:c012:36f5::1/128"
      ];

      trusted_key_servers = [
        {
          server_name = "matrix.org";
          verify_keys."ed25519:a_RXGa" = "l8Hft5qXKn1vfHrg3p4+W8gELQVo8N13JkluMfmn2sQ";
        }
        {
          server_name = "kirottu.com";
          verify_keys."ed25519:a_bNma" = "Sqr3/9MtCFC4tsDSPzDtHWbbX3KOTiYd9uVQBDzW/Rs";
        }
        {
          server_name = "nhnn.dev";
          verify_keys."ed25519:oqKDUz2A" = "O2D+nONSox0MpdjyoKlvael4Q2yld7Or4IJjiG+A2Bs";
        }
      ];

      log_config = (pkgs.formats.yaml { }).generate "log_config" {
        disable_existing_loggers = false;
        formatters = {
          journal_fmt = {
            format = "%(name)s: [%(request)s] %(message)s";
          };
        };
        handlers = {
          journal = {
            SYSLOG_IDENTIFIER = "synapse";
            class = "systemd.journal.JournalHandler";
            formatter = "journal_fmt";
          };
        };
        root = {
          handlers = [
            "journal"
          ];
          level = "WARN";
        };
        version = 1;
      };
      forgotten_room_retention_period = "7d";
      media_retention = {
        remote_media_lifetime = "30d";
      };
    };
  };

  services.synapse-auto-compressor.enable = true;

  #auto-discovery via .well-known
  services.nginx.virtualHosts."zimward.moe" = {
    locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
    locations."= /.well-known/matrix/client".extraConfig = mkWellKnown cfg.clientConfig;
    extraConfig = compressionConf;
  };

  #max nginx request size is 8mb
  services.nginx.clientMaxBodySize = "100M";
  services.nginx.virtualHosts.${cfg.fqdn} = {
    forceSSL = true;
    quic = true;
    enableACME = true;
    listen = lib.lists.flatten (
      map
        (addr: [
          {
            inherit addr;
            port = 8448;
            ssl = true;
          }
          #clients should access via normal https
          {
            inherit addr;
            port = 443;
            ssl = true;
          }
          #for redirects
          {
            inherit addr;
            port = 80;
            ssl = false;
          }
        ])
        [
          "0.0.0.0"
          "[::0]"
        ]
    );
    locations."/_matrix" = proxyConf;
    locations."/_synapse/client" = proxyConf;

    extraConfig = ''
      ${compressionConf}
      access_log /var/log/nginx/matrix_access.log;
      error_log /var/log/nginx/matrix_error.log;
    '';
  };
  #restart matrix after cert change
  security.acme.certs = {
    "zimward.moe" = {
      postRun = "systemctl restart matrix-synapse.service;";
    };
  };
  #allow synapse to read the ssl cert
  users.users."matrix-synapse".extraGroups = [ "nginx" ];

  users.users."nginx".extraGroups = [ "matrix-synapse" ];

  #federation port
  networking.firewall.allowedTCPPorts = [
    port
  ];
  networking.firewall.allowedUDPPorts = [
    port # quic
  ];
}
