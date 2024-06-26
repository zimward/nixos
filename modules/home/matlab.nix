{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    matlab.enable = lib.mkEnableOption "Matlab";
  };
  config = lib.mkIf config.matlab.enable {
    home.sessionPath = ["$HOME/.local/bin"];
    home.file = {
      ".config/matlab/nix.sh" = {
        executable = true;
        text = ''
          INSTALL_DIR=$HOME/.local/share/matlab/
        '';
      };
      ".local/bin/matlab" = {
        executable = true;
        text = ''
          #!${pkgs.dash}/bin/sh
          nix run gitlab:doronbehar/nix-matlab
        '';
      };
    };
  };
}
