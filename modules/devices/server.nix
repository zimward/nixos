{ lib, config, ... }:
{
  config = lib.mkIf (config.device.class == "server") {
    motd.enable = true;
    documentation.enable = false;
    hardware.hddIdle.enable = true;
    xdg = {
      autostart.enable = false;
      icons.enable = false;
      menus.enable = false;
      sounds.enable = false;
      mime.enable = false;
    };
    system.autoUpgrade.allowReboot = true;
    system.autoUpgrade.dates = lib.mkForce "4:00";
  };
}
