{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    graphical.matlab.enable = lib.mkEnableOption "Matlab";
  };
  config = lib.mkIf config.graphical.matlab.enable {
    hm.modules = [
      (
        { ... }:
        {
          #add install dir for matlab
          home.file = {
            ".config/matlab/nix.sh" = {
              executable = true;
              text = ''
                INSTALL_DIR=$HOME/.local/share/matlab/
              '';
            };
          };
        }
      )
    ];
    #provided by the matlab overlay
    environment.systemPackages = [ pkgs.matlab ];
  };
}
