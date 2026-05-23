{
  lib,
  pkgs,
  secrets,
  ...
}:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    enableTCPIP = true;
    enableJIT = true;
    dataDir = "/nix/persist/system/postgres";
    settings = {
      log_destination = lib.mkForce "syslog";
      primary_conninfo = "host=zimward.moe hostaddr=2a01:4f9:c012:36f5:8008:5:0:1 port=5432 user=doga password=${secrets.postgres.doga}";
    };
  };
}
