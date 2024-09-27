{ lib, config, ... }:
{
  options = {
    graphical.enable = lib.mkOption {
      default = config.device.class == "desktop";
      description = "enable graphical applications";
    };
  };
  config.graphical.sway.enable = true;
  imports = [
    ./fonts.nix
    ./applications.nix
    ./sway.nix
    ./ime.nix
    ./kicad.nix
    ./steam.nix
    ./matlab.nix
  ];
}
