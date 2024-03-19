{config, ...}: {
  sops.secrets = {
    "wifi/GvR" = {};
    "wifi/easyroam_ca" = {};
  };
  sops.secrets.easyroam_client_cert = {
    "format" = "binary";
    sopsFile = ../../secrets/easyroam/easyroam_client_cert.pem;
  };
  sops.secrets.easyroam_client_key = {
    "format" = "binary";
    sopsFile = ../../secrets/easyroam/easyroam_client_key.pem;
  };
  sops.secrets.easyroam_root_ca = {
    "format" = "binary";
    sopsFile = ../../secrets/easyroam/easyroam_root_ca.pem;
  };

  networking.networkmanager.ensureProfiles.profiles = {
    eduroam = {
      connection = {
        id = "eduroam";
        type = "wifi";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "eduroam";
      };
      wifi-security = {
        key-mgmt = "wpa-eap";
      };
      "802-1x" = {
        altsubject-matches = "DNS:easyroam.eduroam.de";
        ca-cert = "${config.sops.secrets.easyroam_root_ca.path}";
        client-cert = "${config.sops.secrets.easyroam_client_cert.path}";
        eap = "tls";
        identity = "secret:${config.sops.secrets."wifi/easyroam_ca".path}";
        private-key = "${config.sops.secrets.easyroam_client_key.path}";
      };
      ipv4.method = "auto";
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
    };
    GvR24 = {
      connection = {
        id = "Gerald von Riva";
        type = "wifi";
      };
      ipv4.method = "auto";
      ipv6 = {
        add-gen-mode = "default";
        method = "auto";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "Gerald von Riva 2,4GHz";
      };
      wifi-security = {
        auth-alg = "open";
        key-mgmt = "wpa-psk";
        psk = "secret:${config.sops.secrets."wifi/GvR".path}";
      };
    };
  };
}
