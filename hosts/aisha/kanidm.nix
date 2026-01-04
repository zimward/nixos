{ pkgs, config, ... }:
let
  cfg = config.services.kanidm;
  certDir = "/run/kanidm.ca";
in
{
  systemd.services.kanidm-ca = {
    enable = true;
    unitConfig = {
      Type = "oneshot";
    };
    path = [ pkgs.mkcert ];
    environment.CAROOT = "/run/kanidm.ca";
    environment.TRUST_STORES = " "; # dont install certs
    script = ''
      mkdir $CAROOT -p
      cd $CAROOT
      mkcert -install
      mkcert ${cfg.serverSettings.domain}
      chown kanidm:kanidm /run/kanidm.ca -Rv
      chmod 660 /run/kanidm.ca/* -Rv
    '';
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.kanidm = {
    after = [ "kanidm-ca.service" ];
    wants = [ "kanidm-ca.service" ];
    serviceConfig.BindReadOnlyPaths = "/run/kanidm.ca";
  };
  environment.systemPackages = [ cfg.package ];
  environment.persistence."/nix/persist/system" = {
    directories = [ "/var/lib/kanidm/" ];
  };

  services.kanidm = {
    package = pkgs.kanidm_1_8;
    enableServer = true;
    enableClient = true;
    serverSettings = {
      bindaddress = "[::1]:8443";
      # is read only for now for some reason. needs to be fixed
      # db_path = "/nix/persist/system/kanidm/kanidm.db";
      domain = "idm.zimward.moe";
      origin = "https://idm.zimward.moe";
      tls_chain = "${certDir}/${cfg.serverSettings.domain}.pem";
      tls_key = "${certDir}/${cfg.serverSettings.domain}-key.pem";
    };
    clientSettings = {
      uri = "https://${cfg.serverSettings.bindaddress}";
      ca_path = "${certDir}/rootCA.pem";
      verify_ca = true;
      verify_hostnames = false;
    };
  };
  services.nginx.virtualHosts."idm.zimward.moe" = {
    locations."/" = {
      proxyPass = "https://${cfg.serverSettings.bindaddress}";
      recommendedProxySettings = true;
    };
    quic = true;
    forceSSL = true;
    enableACME = true;
  };
}
