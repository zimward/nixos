{ pkgs, config, ... }:
{
  services.postgresql = {
    enable = true;
    enableJIT = true;
    enableTCPIP = true;
    package = pkgs.postgresql_17;
    dataDir = "/nix/persist/system/postgresql/";
    authentication = ''
      host replication all 2a01:4f9:c012:36f5:8008:5::0/126 scram-sha-256
    '';
    settings = {
      wal_level = "replica";
      max_wal_senders = 5;
      wal_keep_size = "200MB";
    };
  };
  networking.firewall.allowedTCPPorts = [
    config.services.postgresql.settings.port
  ];
}
