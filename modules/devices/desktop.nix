{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.device.class == "desktop") {
    system.tools.nixos-build-vms.enable = lib.mkDefault true;

    environment.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
    };
    net.filter.enable = true;
    #sound
    sys.sound.enable = true;
    #fix for opening links
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
    environment.systemPackages = [ pkgs.nh ];
    nix.package = pkgs.lixPackageSets.latest.lix;
    boot.initrd.systemd.network.wait-online.enable = false;
    systemd.network.wait-online.enable = false;
  };
}
