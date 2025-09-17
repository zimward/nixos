{ pkgs, ... }:
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

  systemd.services.rpi-mcu = {
    wantedBy = [ "klipper.service" ];
    unitConfig.Type = "simple";
    serviceConfig = {
      IOSchedulingClass = "realtime";
      IOSchedulingPriority = 0;
      OOMScoreAdjust = -999;
      User = "moonraker";
      Group = "moonraker";
      ExecStart =
        let
          firmware = pkgs.stdenv.mkDerivation {
            src = pkgs.klipper.src;
            version = pkgs.klipper.version;
            name = "klipper_host_mcu";
            buildInputs = with pkgs; [
              python3
              libffi
              libusb1
              pkg-config
            ];
            configurePhase = ''
              cp ${./config_rpimcu} ./.config
              chmod +w ./.config
              echo qy | { make menuconfig >/dev/null || true; }
              if ! diff ${./config_rpimcu} ./.config; then
                echo " !!! Klipper KConfig has changed. Please run klipper-genconf to update your configuration."
              fi
            '';
            postBuild = "";
            postPatch = ''
              patchShebangs .
            '';
            installPhase = ''
              mkdir -p $out
              cp out/klipper.elf $out/
            '';
            makeFlags = [ "V=1" ];
          };
        in
        "${firmware}/klipper.elf -I /tmp/klipper_host_mcu";
      ExecStop = [
        "sh -c 'echo FORCE_SHUTDOWNN > /tmp/klipper_host_mcu'"
        "sleep 1"
      ];
      TimeoutStopSec = 2;
      Restart = "always";
      RestartSec = 5;
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
    allowSystemControl = true;
  };

  services.mainsail = {
    enable = true;
  };

  services.nginx.clientMaxBodySize = "100M";

  users.groups.gpio = { };

  # Change permissions gpio devices
  services.udev.extraRules = ''
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio",MODE="0660"
    KERNEL=="gpiochip*", GROUP="gpio"
  '';

  # Add user to group
  users.users.moonraker = {
    extraGroups = [ "gpio" ];
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
