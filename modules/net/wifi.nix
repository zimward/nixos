{ lib, config, ... }:
{
  options.net.wifi.enable = lib.mkEnableOption "wifi";
  config = lib.mkIf config.net.wifi.enable {
    sops.secrets = {
      "wifi/GvR" = { };
      "wifi/easyroam_ca" = { };
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
          # identity = "secret:${config.sops.secrets."wifi/easyroam_ca".path}";
          identity = "6889164916985036865@easyroam-pca.htw-berlin.de";
          private-key = "${config.sops.secrets.easyroam_client_key.path}";
          private-key-password = "none";
        };
        ipv4.method = "auto";
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
      };
    };
  };
}
