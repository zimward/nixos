{
  lib,
  inputs,
  pkgs,
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
}
