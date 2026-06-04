{ pkgs, config, ... }:
let
  replicationPeer = "2a01:4f9:c012:36f5:8008:5::0/126";
  port = toString config.services.postgresql.settings.port;
in
{
  services.postgresql = {
    enable = true;
    enableJIT = true;
    enableTCPIP = true;
    package = pkgs.postgresql_17;
    dataDir = "/nix/persist/system/postgresql/";
    authentication = ''
      host replication all ${replicationPeer} scram-sha-256
    '';
    settings = {
      wal_level = "replica";
      max_wal_senders = 5;
      wal_keep_size = "200MB";
    };
  };
  networking.firewall.extraCommands = ''
    ip6tables -A nixos-fw -p tcp --source ${replicationPeer} --dport ${port}:${port} -j nixos-fw-accept
  '';
}
