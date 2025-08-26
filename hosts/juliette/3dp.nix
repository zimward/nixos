{
  services.klipper = {
    enable = true;
    user = "moonraker";
    group = "moonraker";
    configFile = ./printer.cfg;
    logFile = "/var/lib/klipper/klipper.log";
    firmwares = {
      mcu = {
        enable = false;
        configFile = ./config;
        serial = "/dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0";
      };
    };
  };

  services.moonraker = {
    enable = true;
    address = "0.0.0.0";
    settings = {
      authorization = {
        trusted_clients = [
          "192.168.178.0/24"
          "::1/128"
          "127.0.0.0/8"
        ];
        force_logins = false;
        cors_domains = [ "*" ];
      };
    };
  };

  services.mainsail = {
    enable = true;
  };
  #web interface
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
  ];
}
