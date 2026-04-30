{
  pkgs,
  config,
  lib,
  secrets,
  ...
}:
let
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
  fqdn = "matrix.zimward.moe";
  url = "https://${fqdn}";
  clientConfig = {
    "m.homeserver".base_url = url;
    "org.matrix.msc4143.rtc_foci" = [
      {
        "type" = "livekit";
        "livekit_service_url" = "https://${fqdn}/livekit/jwt";
      }
    ];
  };
  serverConfig."m.server" = "${fqdn}:${toString port}";
  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
  certDir = config.security.acme.certs."zimward.moe".directory; # has a sub cert for fqdn
  livekitKeyFile = "/run/livekit.key";
in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    dataDir = "/nix/persist/system/postgresql/";
    ensureUsers = [
      {
        name = "matrix-synapse";
      }
    ];
  };

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
        "127.0.0.0/8"
        "::1"
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
    locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
    #for some reason clients insist on not using the sub domain
    locations."/_matrix" = proxyConf;
    locations."/_synapse/client" = proxyConf;
    extraConfig = compressionConf;
  };
  #max nginx request size is 8mb
  services.nginx.clientMaxBodySize = "100M";
  services.nginx.virtualHosts.${fqdn} = {
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

    locations."^~ /livekit/jwt/" = {
      priority = 400;
      proxyPass = "http://[::1]:${toString config.services.lk-jwt-service.port}/";
    };
    locations."^~ /livekit/sfu/" = {
      extraConfig = ''
        proxy_send_timeout 120;
        proxy_read_timeout 120;
        proxy_buffering off;

        proxy_set_header Accept-Encoding gzip;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';

      priority = 400;
      proxyPass = "http://[::1]:${toString config.services.livekit.settings.port}/";
      proxyWebsockets = true;
    };

    extraConfig = ''
      ${compressionConf}
      access_log /var/log/nginx/matrix_access.log;
      error_log /var/log/nginx/matrix_error.log;
    '';
  };
  services.livekit = {
    enable = true;
    openFirewall = true;
    settings.room.auto_create = false;
    keyFile = livekitKeyFile;
  };
  # generate the key when needed
  systemd.services.livekit-key = {
    before = [
      "lk-jwt-service.service"
      "livekit.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      livekit
      coreutils
      gawk
    ];
    script = ''
      echo "Key missing, generating key"
      echo "lk-jwt-service: $(livekit-server generate-keys | tail -1 | awk '{print $3}')" > "${livekitKeyFile}"
    '';
    serviceConfig.Type = "oneshot";
    unitConfig.ConditionPathExists = "!${livekitKeyFile}";
  };
  services.lk-jwt-service = {
    enable = true;
    # can be on the same virtualHost as synapse
    livekitUrl = "wss://${fqdn}/livekit/sfu";
    keyFile = livekitKeyFile;
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
