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
    ./applications.nix
    ./fonts.nix
    ./ime.nix
    ./kicad.nix
    ./matlab.nix
    ./steam.nix
    ./sway
  ];
}
