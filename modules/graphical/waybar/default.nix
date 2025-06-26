{ config, lib, ... }:
{
  imports = [
    ./settings.nix
  ];
  options.graphical.waybar.enable = lib.mkEnableOption "waybar";
  config = lib.mkIf config.graphical.waybar.enable {
    hm.programs.waybar.enable = true;
  };
}
