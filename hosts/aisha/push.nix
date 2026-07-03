{
  pkgs,
  lib,
  config,
  secrets,
  ...
}:
let
  fqdn = "push.zimward.moe";
  endpointFqdn = "updates.${fqdn}";
  extraConfig = ''
    zstd "on";
    zstd_comp_level 8;
    zstd_min_length 256;
    zstd_types  "text/plain" "text/html" "application/json" "application/xml";
  '';
in
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

  #push gateway

  systemd.services.common-proxies =
    let
      tomlFmt = pkgs.formats.toml { };
      cfg = tomlFmt.generate "common-proxies.toml" {
        listenAddr = "127.0.0.42:5000";
        verbose = true;
        UserAgentID = "zimmy common proxy";
        gateway = {
          matrix.enabled = true;
          aesgcm.enabled = true;
        };
      };
    in
    {
      enable = true;
      after = [ "network.target" ];
      requires = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.unifiedpush-common-proxies} -c ${cfg}";
        Restart = "always";

        MemoryDenyWriteExecute = true;
        StateDirectoryMode = "0700";
        UMask = "077";
        RestartSec = "10s";
        IPAccounting = true;
        MemoryHigh = "50M";
        DynamicUser = true;
        PrivateTmp = "disconnected";
        PrivateDevices = true;
        ProtectSystem = "full";
        ProtectHome = true;
        NoNewPrivileges = true;
        RuntimeDirectoryMode = "755";
        LimitNOFILE = "10032";
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        SystemCallArchitectures = "native";

        ProtectProc = "invisible";
        ProcSubset = "pid";

        SystemCallFilter = [
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@module"
          "~@mount"
          "~@obsolete"
          "~@raw-io"
          "~@reboot"
          "~@swap"
        ];
        SystemCallErrorNumber = "EPERM";

        PrivateUsers = "self";
      };
    };

  # autopush
  services.nginx.virtualHosts = {
    ${fqdn} = {
      forceSSL = true;
      quic = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8180";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
              proxy_connect_timeout		10m;
          		proxy_send_timeout		10m;
          		proxy_read_timeout		10m;
          		client_max_body_size		0;
          		proxy_buffering			off;
          		proxy_request_buffering		off;
          		proxy_redirect			off;
        '';
      };
      inherit extraConfig;
    };
    ${endpointFqdn} = {
      forceSSL = true;
      quic = true;
      enableACME = true;
      #push gateway
      locations."/_matrix/push/v1/notify" = {
        proxyPass = "http://127.0.0.42:5000";
        recommendedProxySettings = true;
      };
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
        recommendedProxySettings = true;
        extraConfig = ''
              proxy_connect_timeout		10m;
          		proxy_send_timeout		10m;
          		proxy_read_timeout		10m;
          		client_max_body_size		0;
          		proxy_pass_request_headers on;
        '';
      };
      inherit extraConfig;
    };
  };
  system.services.autopush-autoconnect = {
    imports = [
      pkgs.autopush-rs.services.autoconnect
    ];
    autoconnect.settings = {
      inherit (secrets.autopush) crypto_key;
      db_dsn = "redis://localhost:${toString config.services.redis.servers.autopush-rs.port}";
      port = 8180;
      endpoint_scheme = "https";
      endpoint_hostname = endpointFqdn;
      endpoint_port = 443;
      hostname = config.networking.hostName;
      human_logs = true;
    };
  };

  system.services.autopush-endpoint = {
    imports = [
      pkgs.autopush-rs.services.autoendpoint
    ];
    autoendpoint.settings = {
      crypto_keys = secrets.autopush.crypto_key;
      db_dsn = "redis://localhost:${toString config.services.redis.servers.autopush-rs.port}";
      port = 8082;
      endpoint_url = "https://${endpointFqdn}";
      human_logs = true;
    };
  };
  systemd.services.autopush-endpoint.environment = {
    RUST_LOG = "info";
  };
  systemd.services.autopush-autoconnect.environment = {
    RUST_LOG = "info";
  };
  services.redis.servers.autopush-rs = {
    enable = true;
    port = 6000;
  };
  environment.persistence."/nix/persist/system" = lib.mkIf config.tmpfsroot.enable {
    directories = [
      "/var/lib/redis-autopush-rs"
    ];
  };
}
