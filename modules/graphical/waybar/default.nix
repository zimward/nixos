{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:
let
  waybar = import ./wrapper.nix { inherit inputs pkgs; };
in
{

  options.graphical.waybar = {
    enable = lib.mkEnableOption "waybar";
    package = lib.mkOption {
      default = waybar.wrapper;
    };
  };
  config = lib.mkIf config.graphical.waybar.enable {
    programs.waybar = {
      enable = true;
      package = waybar.wrapper;
    };
  };
}
