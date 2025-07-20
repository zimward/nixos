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
      address = [
        "192.168.0.1/24"
        "fd98:c5af:e1bc:0::1/64"
      ];
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "both";
        IPv6SendRA = true;
        IPv6AcceptRA = false;
        DHCPPrefixDelegation = true;
      };
      dhcpPrefixDelegationConfig = {
        Announce = true;
        SubnetId = "auto";
      };
      ipv6SendRAConfig = {
        EmitDNS = true;
        Managed = true;
        OtherInformation = true;
      };
      ipv6Prefixes = [
        {
          Prefix = "fd98:c5af:e1bc:0::/64";
        }
      ];
      linkConfig = {
        #jumbo frames
        MTUBytes = 9000;
      };
      dhcpServerConfig = {
        EmitDNS = true;
        PoolOffset = 100;
        DNS = "1.1.1.1";
      };
    };
  };
}
