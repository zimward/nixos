{ ... }:
{
  #actually save the certs
  environment.persistence."/nix/persist/system".directories = [ "/var/lib/acme" ];

  users.users."stalwart-mail".extraGroups = [ "nginx" ];

  #mail service
  services.stalwart-mail = {
    enable = true;
    openFirewall = true;
    dataDir = "/nix/persist/mail";
    settings = {
      server = {
        hostname = "mx1.zimward.moe";
        tls = {
          enable = true;
          implicit = true;
        };
        listener = {
          smpt = {
            protocol = "smtp";
            bind = "[::]:25";
          };
          smpts = {
            protocol = "smtp";
            bind = "[::]:465";
            tls = true;
          };
          imaps = {
            bind = "[::]:993";
            protocol = "imap";
            tls = true;
          };
          web = {
            protocol = "http";
            bind = "[::]:8000";
          };
        };
      };
      lookup.default = {
        hostname = "mx1.zimward.moe";
        domain = "zimward.moe";
      };
      certificate.default = {
        cert = "%{file:/var/lib/acme/zimward.moe/cert.pem}%";
        private-key = "%{file:/var/lib/acme/zimward.moe/key.pem}%";
      };
      storage = {
        encryption = {
          enable = true;
          append = true;
        };
        data = "postgresql";
        blob = "postgresql";
        fts = "postgresql";
        lookup = "postgresql";
        directory = "internal";
      };
      store."postgresql" = {
        type = "postgresql";
        host = "localhost";
        port = 5432;
        database = "stalwart";
        user = "stalwart";
        password = "whydoyouneedone";
        compression = "lz4";
        query = {
          name = "SELECT name, type, secret, description, quota FROM accounts WHERE name = $1 AND active = true";
          members = "SELECT member_of FROM group_members WHERE name = $1";
          recipients = "SELECT name FROM emails WHERE address = $1 ORDER BY name ASC";
          emails = "SELECT address FROM emails WHERE name = $1 ORDER BY type DESC, address ASC";
        };
      };
      directory."internal" = {
        store = "postgresql";
      };
      # session.auth = {
      #   mechanisms = "[plain]";
      #   directory = "'in-memory'";
      # };
      # storage.directory = "in-memory";
      # directory."in-memory" = {
      #   type = "memory";
      #   principals = [
      #     {
      #       class = "individual";
      #       name = "Aisha";
      #       secret = "%{file:/nix/persist/mail/aisha-pw}%";
      #       email = [ "aisha@zimward.moe" ];
      #     }
      #   ];
      # };
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/nix/persist/mail/admin-pw}%";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    25
    465
    993
  ];
}
