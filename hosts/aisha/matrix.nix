{ pkgs, config, ... }:
let
  port = 8448;
  fqdn = "zimward.moe";
  url = "https://${fqdn}";
  clientConfig."m.homeserver".base_url = url;
  serverConfig."m.server" = "${fqdn}:${builtins.toString port}";
  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
  certDir = config.security.acme.certs.${fqdn}.directory;
in
{
  services.postgresql = {
    enable = true;
    dataDir = "/nix/persist/system/postgresql/";
  };
  services.matrix-synapse = {
    enable = true;
    dataDir = "/nix/persist/system/matrix-synapse/";
    settings = {
      registration_shared_secret = "Y2q16w4KrsXxwsE1QvBBMb4a716I3qhaZxzUR6uVcNdVOmKhCLoDCTngkMJk99Ot";
      server_name = "zimward.moe";
      public_baseurl = "https://zimward.moe";
      tls_certificate_path = "${certDir}/fullchain.pem";
      tls_private_key_path = "${certDir}/key.pem";
      extraConfig = ''
        max_upload_size: "100M"
      '';
      listeners = [
        {
          inherit port;
          bind_addresses = [
            "zimward.moe"
          ];
          type = "http";
          tls = true;
          x_forwarded = false;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = true;
            }
          ];
        }
        {
          port = 8008;
          bind_addresses = [
            "::1"
          ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = true;
            }
          ];
        }
      ];
      turn_uris = [
        "turn:${fqdn}:3478?transport=udp"
        "turn:${fqdn}:3478?transport=tcp"
      ];
      turn_shared_secret = config.services.coturn.static-auth-secret;
      turn_user_lifetime = "1h";
      turn_allow_guests = true;
      log_config = (pkgs.formats.yaml { }).generate "log_config" {
        disable_existing_loggers = true;
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
    };
  };
  #auto-discovery via .well-known
  services.nginx.virtualHosts."${fqdn}" = {
    locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
    locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
    locations."/_matrix".proxyPass = "http://[::1]:8008";
    locations."/_synapse/client".proxyPass = "http://[::1]:8008";
  };
  #restart matrix after cert change
  security.acme.certs = {
    "zimward.moe" = {
      postRun = "systemctl restart matrix-synapse.service; systemctl restart coturn.service;";
    };
  };
  #allow synapse to read the ssl cert
  users.users."matrix-synapse".extraGroups = [ "nginx" ];

  #coturn for audio calls
  services.coturn = {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret = "YS8MDZEFOe4BF6N8DVsPVUmQWfdCe4XxVIbJVKzGbn3zssZdoc1tGTlfDZ575VeU";
    realm = fqdn;
    cert = "${certDir}/full.pem";
    pkey = "${certDir}/key.pem";
    extraConfig = ''
      # ban private IP ranges
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };

  users.users."turnserver".extraGroups = [ "nginx" ];

  networking.firewall.allowedUDPPortRanges = [
    {
      from = config.services.coturn.min-port;
      to = config.services.coturn.max-port;
    }
  ];

  #federation port + coturn
  networking.firewall.allowedTCPPorts = [
    port
    3478
    5349
  ];
  networking.firewall.allowedUDPPorts = [
    3478
    5349
  ];
}
