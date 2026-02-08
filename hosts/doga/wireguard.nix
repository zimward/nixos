{ pkgs, ... }:
let
  table = 1337;
in
{
  systemd.network.networks."50-wg" = {
    matchConfig.Name = "wg0";

    address = [
      "2a01:4f9:c012:36f5:8008:5::2/128"
    ];
    routingPolicyRules = [
      {
        Table = table;
        User = "minecraft";
        Priority = 30000;
        Family = "ipv6";
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
        RouteTable = table;
      }
    ];
  };
  networking.firewall.extraCommands = ''
    ${pkgs.iproute2}/bin/ip -6 rule add iif wg0 lookup ${toString table}
    ${pkgs.iproute2}/bin/ip -6 rule add oif wg0 lookup ${toString table}
  '';

  environment.persistence."/nix/persist/system" = {
    directories = [ "/etc/credstore" ];
  };
}
