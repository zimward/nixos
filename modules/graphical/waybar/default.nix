{
  config,
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

  options.graphical.waybar.enable = lib.mkEnableOption "waybar";
  config = lib.mkIf config.graphical.waybar.enable {
    environment.systemPackages = [ waybar.wrapper ];
  };
}
