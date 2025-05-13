{ lib, ... }:
{
  options.net.sycthing.enable = lib.mkEnableOption "Syncthing";
  config = lib.mkIf {

  };
}
