{
  lib,
  inputs,
  pkgs,
  ...
}:
let
  waybar = inputs.wrappers.wrapperModules.waybar.apply (
    {
      inherit pkgs;
    }
    // (import ./settings.nix pkgs)
  );
in
{

  options.graphical.waybar = {
    enable = lib.mkEnableOption "waybar";
    package = lib.mkOption {
      default = waybar.wrapper;
    };
  };
}
