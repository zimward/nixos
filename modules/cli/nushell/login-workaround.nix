{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.cli.nushell.graphical_startup = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    description = "graphical startup command";
    default = null;
  };
  config = lib.mkIf (config.cli.nushell.enable && config.cli.nushell.graphical_startup != null) {
    users.users."${config.mainUser.userName}".shell = lib.mkForce pkgs.bash;
    programs.bash = {
      loginShellInit = ''
        if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
          exec ${config.cli.nushell.graphical_startup}
        fi
      '';
    };
  };
}
