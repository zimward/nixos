{
  systemd.network.networks."50-wg" = {
    matchConfig.Name = "wg0";

    address = [
      "2a01:4f9:c012:36f5:8008:5000::2/64"
    ];
  };
  systemd.network.netdevs."50-wg" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
    };
    wireguardConfig = {
      ListenPort = 51820;
      PrivateKey = "@network.wireguard.private";
      FirewallMark = 42;
    };
    wireguardPeers = [
      {
        PublicKey = "t3VeC2k0f/9dJSiTFR9Foo2caMkxTYuygnhX67FANUE=";
        AllowedIPs = [ "::/0" ];
        Endpoint = "[2a01:4f9:c012:36f5::1]:51820";
      }
    ];
  };

  environment.persistence."/nix/persist/system" = {
    directories = [ "/etc/credstore" ];
  };
}
