{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    automount.enable = lib.mkOption {
      default = true;
      description = "weather to enable automounting";
    };
  };
  config = lib.mkIf config.automount.enable {
    services.udisks2.enable = true;
    services.gvfs.enable = true;
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect --owner ${config.main-user.userName} $devnode"
    '';
  };
}
