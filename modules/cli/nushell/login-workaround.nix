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
  #only use this on graphical to work around fcitx5
  config = lib.mkIf (config.cli.nushell.enable && config.cli.nushell.graphical_startup != null) {
    users.users."${config.main-user.userName}".shell = lib.mkForce pkgs.bash;
    #start nushell if run inside alacritty
    programs.bash = {
      loginShellInit = ''
        if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
          exec ${config.cli.nushell.graphical_startup}
        fi
      '';
    };
  };
}
