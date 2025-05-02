{ lib, config, ... }:
{
  config = lib.mkIf (config.device.class == "server") {
    motd.enable = true;
    documentation.enable = false;
    system.autoUpgrade.allowReboot = true;
    system.autoUpgrade.dates = lib.mkForce "4:00";
  };
}
