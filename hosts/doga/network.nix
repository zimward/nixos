{ config, ... }: {
  config = {
    networking.useDHCP = false;
    systemd.network.enable = true;
    networking.useNetworkd = true;
    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [
      22
      111
      2049
      4000
      4001
      4002
      20048
      #ethercalc
      8000
      # harmonia cache
      5000
    ];
    networking.firewall.allowedUDPPorts = [
      2049
      111
      4000
      4001
      4002
      20048
    ];
    networking.firewall.enable = true;
    #local intranet interface
    networking.firewall.trustedInterfaces = [
      config.ethernet.share.device
      "virbr0"
    ];

    #bridge for VMs
    networking.bridges = {
      virbr0 = {
        interfaces = [ "enp8s0f0" ];
      };
    };

    #public interface with ipv6 config
    systemd.network.networks."10-public" = {
      matchConfig.Name = "virbr0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        DHCPPrefixDelegation = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
    systemd.network.wait-online.anyInterface = true;
    systemd.network.wait-online.ignoredInterfaces = [
      "wg0"
      "enp8s0f0" # base10G public interface
    ];
  };
}
