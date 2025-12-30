{
  config,
  lib,
  ...
}:
let
  cfg = config.hardware.backlight;
in
{
  options.hardware.backlight = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable backlight setup on startup";
      default = config.device.class == "desktop";
    };
    level = lib.mkOption {
      type = lib.types.ints.between 0 255;
      description = "brightness on startup. check max_brightness";
      default = 3;
    };
  };
  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''SUBSYSTEM=="backlight", ACTION=="add", KERNEL=="acpi_video0", ATTR{brightness}="${toString cfg.level}"'';
  };
}
