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
    #add install dir for matlab
    hm.home.file = {
      ".config/matlab/nix.sh" = {
        executable = true;
        text = ''
          INSTALL_DIR=$HOME/.local/share/matlab/
        '';
      };
    };
    #provided by the matlab overlay
    environment.systemPackages = [ pkgs.matlab ];
  };
}
