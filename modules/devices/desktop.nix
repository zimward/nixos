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
      DNSSEC = true;
      DNSOverTLS = "opportunistic";
    };

    security.soteria.enable = true;

    xdg.mime.defaultApplications = {
      "application/pdf" = "firefox.desktop";
    };

    #sound
    sys.sound.enable = true;
    environment.systemPackages = [
      pkgs.npins
      pkgs.nix-output-monitor
    ];
    boot.initrd.systemd.network.wait-online.enable = false;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    systemd.network.wait-online.enable = false;

    services.harmonia.cache.enable = true; # Serve up local Nix store
    networking.firewall.allowedTCPPorts = [ 5000 ]; # Open firewall port for Harmonia
  };
}
