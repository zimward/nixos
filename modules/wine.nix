{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    enable = lib.mkDefault true;
  };
  config = lib.mkIf config.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      wineWowPackages.waylandFull
      winetricks
    ];
  };
}
