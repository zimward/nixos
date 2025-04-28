{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.device.class == "desktop") {
    latex = true;
    devel = {
      helix.enable = true;
      git.enable = true;
      zellij.enable = true;
    };
    environment.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
    };
    net.filter.enable = true;
    #running ssh agent on graphical hosts is most often needed
    cli.ssh.enableAgent = true;
    #sound
    sys.sound.enable = true;
    #fix for opening links
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
    environment.systemPackages = [ pkgs.nh ];
  };
}
