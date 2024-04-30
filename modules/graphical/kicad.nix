{ lib, config, pkgs, ...}:{
  options = {
    graphical.kicad.enable = lib.mkOption {
      default = true;
      description = "enable kicad and other EE programms";
    };
  };
  config = lib.mkIf config.graphical.enable && config.graphical.kicad.enable {
    environment.systemPackages = with pkgs; [
      kicad
    ];
  };
}
