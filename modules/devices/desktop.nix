{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ../graphical ];
  config = lib.mkIf (config.device.class == "desktop") {
    system.tools.nixos-build-vms.enable = lib.mkDefault true;

    devel.git.enable = true;
    cli.applications.enable = true;

    services.getty.autologinUser = config.mainUser.userName;
    services.getty.autologinOnce = true;
    #nitrokey support
    services.udev.packages = [ pkgs.nitrokey-udev-rules ];

    environment.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
    };

    services.resolved.settings.Resolve = {
      DNSSEC = lib.mkDefault "true";
      DNSOverTLS = "true";
      LLMNR = "true";
      Domains = [ "~." ];
    };

    security.soteria.enable = true;
    systemd.user.services.polkit-soteria = {
      restartTriggers =
        if lib.versionAtLeast "0.3.1" pkgs.soteria.version then
          [ config.system.path ]
        else
          throw "soteria updated! it now reregisters agent!";
    };

    xdg.mime.defaultApplications = {
      "application/pdf" = "firefox.desktop";
    };

    #sound
    sys.sound.enable = true;
    environment.systemPackages = [ pkgs.nh ];
    boot.initrd.systemd.network.wait-online.enable = false;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    systemd.network.wait-online.enable = false;

    services.nix-cache-beacon = {
      advert = {
        enable = true;
        port = 5000; # Harmonia port
      };

      # Enable local binary cache using discovered caches on the local network
      cache.enable = true;
    };

    # Make Nix aware of our local network cache
    nix.settings.substituters = [ "http://localhost:5028" ];

    services.harmonia.cache.enable = true; # Serve up local Nix store
    networking.firewall.allowedTCPPorts = [ 5000 ]; # Open firewall port for Harmonia
  };
}
