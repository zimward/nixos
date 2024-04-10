{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    enable = lib.mkOption {
      default = true;
      description = "Enable wine packages";
    };
  };
  config = lib.mkIf config.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      wineWowPackages.waylandFull
      winetricks
    ];
  };
}
