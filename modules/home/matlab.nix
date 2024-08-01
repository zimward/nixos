{
  lib,
  pkgs,
  syscfg,
  ...
}:
{
  config = lib.mkIf syscfg.graphical.matlab.enable {
    home.file = {
      ".config/matlab/nix.sh" = {
        executable = true;
        text = ''
          INSTALL_DIR=$HOME/.local/share/matlab/
        '';
      };
    };
  };
}
