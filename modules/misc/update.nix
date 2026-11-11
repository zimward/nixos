{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sys.update;
in
{
  options.sys.update = {
    enable = lib.mkEnableOption "Automatic system update";
    cfgRef = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "git+ssh://git@zimward.moe/~/nixos";
      description = "reference to nixos config";
    };
    accessKey = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = "/etc/ssh/ssh_host_ed25519_key";
    };
    date = lib.mkOption {
      type = lib.types.str;
      default = "10:00";
    };
    allowReboot = lib.mkEnableOption "allow automatic reboots";
  };
  config = {
    systemd.timers.systemUpdate = {
      enable = cfg.enable;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.date;
        Unit = "systemUpdate.service";
        Persistent = true;
        RandomizedDelaySec = "5min";
      };
    };

    systemd.services.systemUpdate = {
      enable = cfg.enable;
      path = [
        pkgs.git
        config.programs.ssh.package
        config.nix.package.out
        config.systemd.package
      ];
      environment = {
        REBOOT = if cfg.allowReboot then "1" else "0";
        GIT_SSH_COMMAND = "ssh -i ${cfg.accessKey}";
        REPO = cfg.cfgRef;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.nushell} -c 'source ${../cli/nushell/syscli.nu}; source ${./update.nu}'";
      };
    };
  };
}
