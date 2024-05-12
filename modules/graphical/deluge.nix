{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    graphical.deluge.enable = lib.mkOption {
      default = false;
      description = "Enable deluge";
    };
  };
  config = lib.mkIf config.graphical.deluge.enable {
    environment.systemPackages = with pkgs; [
      deluge
    ];
  };
}
