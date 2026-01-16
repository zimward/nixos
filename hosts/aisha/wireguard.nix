{

  systemd.network.networks."50-wg" = {
    matchConfig.Name = "wg0";

    address = [
      "2a01:4f9:c012:36f5:8008:5::1/128"
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
    };
    wireguardPeers = [
      {
        PublicKey = "5w5ZFLaanz8cmGaMu6tQi3uR4YWdA0BMGWEAyGogSAk=";
        AllowedIPs = [ "2a01:4f9:c012:36f5:8008:5::2/128" ];
      }
    ];
  };

  environment.persistence."/nix/persist/system" = {
    directories = [ "/etc/credstore" ];
  };
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    trustedInterfaces = [ "wg0" ];
    extraCommands = ''
      ip6tables -A FORWARD -i enp1s0 -o wg0 -d 2a01:4f9:c012:36f5:8008:5::2/128 -j ACCEPT
      ip6tables -A FORWARD -i wg0 -o enp1s0 -s 2a01:4f9:c012:36f5:8008:5::2/128 -j ACCEPT
    '';
  };
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
  };
}
