{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    hardware.hddIdle = lib.mkOption {
      description = "List of HDDs to put into idle mode";
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
    };
    hardware.hddIdleTime = lib.mkOption {
      description = "Time for hdd to go into idle. In multiple of 5s intervals";
      type = lib.types.int;
      default = 200;
    };
  };
  config = lib.mkIf (config.hardware.hddIdle != null) {
    systemd.services.hdd-idle = {
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        StopWhenUnneeded = "yes";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = map (
          hdd: "${lib.getExe pkgs.hdparm} -S ${builtins.toString config.hardware.hddIdleTime} /dev/${hdd}"
        ) config.hardware.hddIdle;
      };
    };
  };
}
