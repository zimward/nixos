{
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "enp1s0";
    internalInterfaces = [ "wg0" ];
  };
  systemd.network.networks."50-wg" = {
    matchConfig.Name = "wg0";

    address = [
      "2a01:4f9:c012:36f5:8008:5000::1/64"
    ];

    networkConfig = {
      IPv6Forwarding = true;
    };
  };
  systemd.network.netdevs."50-wg" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
    };
    wireguardConfig = {
      ListenPort = 51820;
      PrivateKey = "@network.wireguard.private";
      RouteTable = "main";
      FirewallMark = 42;
    };
    wireguardPeers = [
      {
        PublicKey = "5w5ZFLaanz8cmGaMu6tQi3uR4YWdA0BMGWEAyGogSAk=";
        AllowedIPs = [ "::/0" ];
      }
    ];
  };

  environment.persistence."/nix/persist/system" = {
    directories = [ "/etc/credstore" ];
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];
}
