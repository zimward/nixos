{ ... }:
{
  #actually save the certs
  environment.persistence."/nix/persist/system".directories = [ "/var/lib/acme" ];
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
          };
          imaps = {
            bind = "[::]:993";
            protocol = "imap";
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
      storage.encryption = {
        enable = true;
        append = true;
      };
      webadmin = {
        resource = "file:///nix/persist/mail/webadmin.zip";
        auto-update = true;
      };
    };
  };
}
