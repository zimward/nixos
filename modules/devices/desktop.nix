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
    #nitrokey support
    services.udev.packages = [ pkgs.nitrokey-udev-rules ];

    environment.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
    };

    services.resolved.settings.Resolve = {
      DNSSEC = lib.mkDefault "true";
      DNSOverTLS = "true";
      LLMNR = "false";
      Domains = [ "~." ];
    };

    security.soteria.enable = true;
    systemd.user.services.niri-flake-polkit.enable = lib.mkForce false;

    net.filter.enable = true;
    #sound
    sys.sound.enable = true;
    #fix for opening links
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
    environment.systemPackages = [ pkgs.nh ];
    nix.package = pkgs.nixVersions.latest;
    boot.initrd.systemd.network.wait-online.enable = false;
    boot.bootspec.enable = true;
    systemd.network.wait-online.enable = false;
  };
}
