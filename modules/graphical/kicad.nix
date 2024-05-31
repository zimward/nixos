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
      unstable = lib.mkOption {
        default = false;
      };
      minimal = lib.mkOption {
        default = false;
      };
    };
  };
  config = lib.mkIf (config.graphical.enable && config.graphical.kicad.enable) {
    environment.systemPackages = with pkgs;
      lib.mkIf (config.graphical.kicad.unstable && !config.graphical.kicad.minimal) [unstable.kicad];
    # ++ lib.mkIf (config.graphical.kicad.unstable && config.kicad.minimal) [unstable.kicad-small]
    # ++ lib.mkIf (!config.graphical.kicad.unstable && !config.graphical.kicad.minimal) [kicad]
    # ++ lib.mkIf (!config.graphical.kicad.unstable && config.kicad.minimal) [kicad-small];
  };
}
