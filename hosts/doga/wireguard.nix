{
  systemd.network.networks."50-wg" = {
    matchConfig.Name = "wg0";

    address = [
      "2a01:4f9:c012:36f5:8008:5::2/128"
    ];
    routingPolicyRules = [
      {
        Table = 1337;
      }
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
    };
    wireguardPeers = [
      {
        PublicKey = "t3VeC2k0f/9dJSiTFR9Foo2caMkxTYuygnhX67FANUE=";
        AllowedIPs = [ "::/0" ];
        Endpoint = "[2a01:4f9:c012:36f5::1]:51820";
        PersistentKeepalive = 25;
      }
    ];
  };
  networking.firewall.checkReversePath = "loose";

  environment.persistence."/nix/persist/system" = {
    directories = [ "/etc/credstore" ];
  };
}
