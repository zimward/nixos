{
  inputs,
  pkgs,
  ...
}:
let
  cfgFile = pkgs.writeText "config.toml" ''
    url = "https://arcu.dyndns.org/imgserv"
    data_dir = "/var/lib/imgserv/"
    image_ttl = 1209600
    cleanup_interval = 21600
  '';
in
{
  config = {
    users.users."imgserv" = {
      isSystemUser = true;
      group = "imgserv";
    };
    users.groups.imgserv = { };
    systemd.services.imgserv = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        User = "imgserv";
        Group = "imgserv";
        Environment = [
          "CONFIG_FILE=${cfgFile}"
          "ROCKET_ADDRESS=::"
        ];
        ExecStart = [ "${inputs.imgserv.packages.aarch64-linux.default}/bin/imgserv" ];
        StateDirectory = "/var/lib/imgserv";
        MemoryDenyWriteExecute = "yes";
        NoNewPriviledges = "yes";
        PrivateDevices = "yes";
        PrivateUsers = "yes";
        ProtectControlGroups = "yes";
        ProtectHome = "yes";
        ProtectHostname = "yes";
        ProtectKernelLogs = "yes";
        ProtectKernelModules = "yes";
        ProtectTunables = "yes";
        ProtectSystem = "full";
        RestrictRealtime = "yes";
        SystemCallFilter = [
          "~@privileged @resources"
          "@system-service"
        ];
        SystemCallArchitectures = "native";
        CapabilityBoundingSet = "";
        RestrictAddressFamilies = "AF_INET AF_INET6";
      };

    };
  };
}
