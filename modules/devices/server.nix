{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.device.class == "server") {
    motd.enable = true;
    documentation.enable = false;
    hardware.hddIdle.enable = true;
    services.resolved.settings.Resolve.DNSSEC = "false";
    services.logrotate.enable = true;

    #causes log to grow too much, doesn't provide much value either
    networking.firewall.logRefusedConnections = lib.mkDefault false;

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    xdg = {
      autostart.enable = false;
      icons.enable = false;
      menus.enable = false;
      sounds.enable = false;
      mime.enable = false;
    };

    fonts.fontconfig.enable = false;

    #don't ask for a password on servers after initial login
    security.polkit.extraConfig = ''
      polkit.addRule(function(action,subject){
        if (action.id == "org.freedesktop.systemd1.manage-units" && subject.active && subject.user =="${config.mainUser.userName}"){
          return polkit.Result.YES;
        }
      });
    '';

    sys.update.allowReboot = true;
    sys.update.date = lib.mkForce "4:00";

    #should never be needed
    security.lockKernelModules = true;
    #disable ptrace
    boot.kernel.sysctl = {
      "kernel.yama.ptrace_scope" = 3;
    };
  };
}
