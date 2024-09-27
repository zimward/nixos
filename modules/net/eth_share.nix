{ config, lib, ... }:
{
  options = {
    ethernet.share.device = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
      description = "Interface to masqerade";
    };
  };

  config = lib.mkIf (config.ethernet.share.device != null) {
    systemd.network.enable = true;
    networking.useNetworkd = true;
    systemd.network.networks."10-share" = {
      enable = true;
      matchConfig = {
        Name = config.ethernet.share.device;
      };
      address = [ "192.168.0.1/24" ];
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "both";
      };
      dhcpServerConfig = {
        EmitDNS = true;
        PoolOffset = 100;
        DNS = "1.1.1.1";
      };
    };
  };
}
