{
  lib,
  config,
  ...
}: {
  options = {
    tmpfsroot.enable = lib.mkOption {
      default = false;
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
    tmpfsroot.boot = lib.mkOption {
      type = lib.types.attrs;
      description = "file system of boot partition (esp)";
    };
  };
  config = lib.mkIf config.tmpfsroot.enable {
    fileSystems."/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["noexec"];
    };
    fileSystems."/nix" = config.tmpfsroot.nixstore;
    fileSystems."/home" = config.tmpfsroot.home;
    #umask to close potential security hole of stored inital seed
    fileSystems."/boot" = lib.mkMerge [config.tmpfsroot.boot {options = ["umask=0077"];}];
    sops.age.keyFile = lib.mkForce "/nix/persist/system/var/lib/sops-nix/key.txt";
    programs.fuse.userAllowOther = true;
  };
}
