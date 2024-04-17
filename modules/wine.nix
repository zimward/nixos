{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    wine.enable = lib.mkOption {
      default = true;
      description = "Enable wine packages";
    };
  };
  config = lib.mkIf config.wine.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      wineWowPackages.waylandFull
      winetricks
    ];
  };
}
