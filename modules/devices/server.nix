{
  lib,
  config,
  modulesPath,
  ...
}:
{
  # imports = [ "${modulesPath}/profiles/minimal.nix" ];
  config = lib.mkIf (config.device.class == "server") {
    motd.enable = true;
    documentation.enable = false;
    hardware.hddIdle.enable = true;
    services.resolved.dnssec = "false";
    services.logrotate.enable = true;

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

    system.autoUpgrade.allowReboot = true;
    system.autoUpgrade.dates = lib.mkForce "4:00";

    #disable ptrace
    boot.kernel.sysctl = {
      "kernel.yama.ptrace_scope" = 3;
    };
  };
}
