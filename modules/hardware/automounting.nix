{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {
    automount.enable = lib.mkOption {
      default = true;
      description = "weather to enable automounting";
    };
  };
  config = lib.mkIf config.automount.enable {
    services.udisks2.enable = true;
    services.gvfs.enable = true;
  };
}
