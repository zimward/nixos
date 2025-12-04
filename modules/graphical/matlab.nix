{
  inputs,
  lib,
  config,
  ...
}:
{
  options = {
    graphical.matlab.enable = lib.mkEnableOption "Matlab";
  };
  config = lib.mkIf config.graphical.matlab.enable {
    #provided by the matlab overlay
    environment.systemPackages = [ inputs.nix-matlab.packages.x86_64-linux.matlab ];
  };
}
