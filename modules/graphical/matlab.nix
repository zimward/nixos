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
  #provided by the matlab overlay
  config = lib.mkIf config.graphical.matlab.enable { environment.systemPackages = [ pkgs.matlab ]; };
}
