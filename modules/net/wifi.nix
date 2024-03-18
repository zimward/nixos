{config, ...}: {
  sops.secrets = {
    "wifi/GvR" = {};
  };
  # sops.templates."wifi-psk".content = ''
  #   pks
  # '';

  networking.networkmanager.ensureProfiles.profiles = {
    GvR24 = {
      connection = {
        id = "Gerald von Riva";
        type = "wifi";
      };
      ipv4 = {
        method = "auto";
      };
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
