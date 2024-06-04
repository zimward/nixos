{
  lib,
  config,
  pkgs,
  unstable,
  ...
}:
let
  alt = cond: pkg: (if cond then [ pkg ] else [ ]);
in
{
  options = {
    graphical.kicad = {
      enable = lib.mkOption {
        default = true;
        description = "enable kicad and other EE programms";
      };
      unstable = lib.mkOption {
        default = false;
      };
      minimal = lib.mkOption {
        default = false;
      };
    };
  };
  config = lib.mkIf (config.graphical.enable && config.graphical.kicad.enable) {
    environment.systemPackages =
      [ ]
      ++ alt (config.graphical.kicad.unstable && !config.graphical.kicad.minimal) unstable.kicad
      ++ alt (config.graphical.kicad.unstable && config.graphical.kicad.minimal) unstable.kicad-small
      ++ alt (!config.graphical.kicad.unstable && !config.graphical.kicad.minimal) pkgs.kicad
      ++ alt (!config.graphical.kicad.unstable && config.graphical.kicad.minimal) pkgs.kicad-small;
  };
}
