{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    hardware.hddIdle.enable = lib.mkEnableOption "hdd idle rules";
    hardware.hddIdle.time = lib.mkOption {
      description = "Time for hdd to go into idle. In multiple of 5s intervals";
      type = lib.types.int;
      default = 400;
    };
  };
  config = lib.mkIf config.hardware.hddIdle.enable {
    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${lib.getExe pkgs.hdparm} -B 127 -S ${builtins.toString config.hardware.hddIdle.time} /dev/%k"
    '';
  };
}
