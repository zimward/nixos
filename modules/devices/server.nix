{ lib, config, ... }:
{
  config = lib.mkIf (config.device.class == "server") {
    motd.enable = true;
    documentation.enable = false;
  };
}
