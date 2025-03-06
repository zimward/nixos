{ ... }:
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
in
{
  services.postgresql.enable = true;
  services.matrix-synapse = {
    enable = true;
    settings = {
      registration_shared_secret = "Y2q16w4KrsXxwsE1QvBBMb4a716I3qhaZxzUR6uVcNdVOmKhCLoDCTngkMJk99Ot";
      server_name = "zimward.moe";
      public_baseurl = "https://zimward.moe";
      tls_certificate_path = "/var/lib/acme/zimward.moe/fullchain.pem";
      tls_private_key_path = "/var/lib/acme/zimward.moe/key.pem";
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
      postRun = "systemctl restart matrix-synapse.service";
    };
  };
  #allow synapse to read the ssl cert
  users.users."matrix-synapse".extraGroups = [ "nginx" ];

  #federation port
  networking.firewall.allowedTCPPorts = [ port ];
}
