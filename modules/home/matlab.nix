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
          #!${pkgs.bash}/bin/bash
          nix run gitlab:doronbehar/nix-matlab
        '';
      };
    };
  };
}
