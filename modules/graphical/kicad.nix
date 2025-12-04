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
        default = config.device.class == "desktop";
        description = "enable kicad and other EE programms";
      };
      minimal = lib.mkOption { default = false; };
    };
  };
  config = lib.mkIf (config.graphical.enable && config.graphical.kicad.enable) {
    environment.systemPackages =
      let
        withAddons =
          p:
          p.override {
            addons = with pkgs.kicadAddons; [
              kikit
              kikit-library
            ];
          };
      in
      if config.graphical.kicad.minimal then
        [ (withAddons pkgs.kicad-small) ]
      else
        [ (withAddons pkgs.kicad-small) ];
  };
}
