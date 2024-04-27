{
  lib,
  config,
  ...
}: {
  options = {
    tmpfsroot.enable = lib.mkOption {
      default = true;
      description = "enable Tmpfs root fs";
    };
    tmpfsroot.nixstore = lib.mkOption {
      type = lib.types.attrs;
      description = "mount point of the nixos store";
    };
    tmpfsroot.home = lib.mkOption {
      type = lib.types.attrs;
      description = "mount point of home partion/fs";
    };
  };
  config = lib.mkIf config.tmpfsroot.enable {
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["size=2G" "mode=755"];
    };
    fileSystems."/nix" = config.tmpfsroot.nixstore;
    fileSystems."/home" = config.tmpfsroot.home;
  };
}
