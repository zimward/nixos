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
      };
      directory."internal" = {
        store = "postgresql";
      };
      # authentication.fallback-admin = {
      #   user = "admin";
      #   secret = "%{file:/nix/persist/mail/admin-pw}%";
      # };
      auth.dkim = {
        sign = [
          {
            "if" = "listener != 'smtp'";
            "then" = "['rsa','ed25519']";
          }
          {
            "else" = false;
          }
        ];
      };
      signature.rsa = {
        private-key = "%{file:/nix/persist/mail/dkim_priv_rsa.pem}%";
        domain = "zimward.moe";
        selector = "rsamail";
        headers = [
          "From"
          "To"
          "Cc"
          "Date"
          "Subject"
          "Message-ID"
          "Organization"
          "MIME-Version"
          "Content-Type"
          "In-Reply-To"
          "References"
          "List-Id"
          "User-Agent"
          "Thread-Topic"
          "Thread-Index"
        ];
        algorithm = "rsa-sha256";
        canonicalization = "relaxed/relaxed";
        report = true;
      };
      signature.ed25519 = {
        private-key = "%{file:/nix/persist/mail/dkim_priv_ed25519.pem}%";
        domain = "zimward.moe";
        selector = "edmail";
        headers = [
          "From"
          "To"
          "Cc"
          "Date"
          "Subject"
          "Message-ID"
          "Organization"
          "MIME-Version"
          "Content-Type"
          "In-Reply-To"
          "References"
          "List-Id"
          "User-Agent"
          "Thread-Topic"
          "Thread-Index"
        ];
        algorithm = "ed25519-sha256";
        canonicalization = "relaxed/relaxed";
        report = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    25
    465
    993
  ];
}
