{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    graphical.kicad = {
      enable = lib.mkOption {
        default = true;
        description = "enable kicad and other EE programms";
      };
      minimal = lib.mkOption { default = false; };
    };
  };
  config = lib.mkIf (config.graphical.enable && config.graphical.kicad.enable) {
    environment.systemPackages =
      if config.graphical.kicad.minimal then [ pkgs.kicad-small ] else [ pkgs.kicad ];
  };
}
