{ lib, ... }:
{
  options = {
    graphical.enable = lib.mkOption {
      default = true;
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
