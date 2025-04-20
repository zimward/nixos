{ lib, config, ... }:
{
  options = {
    tmpfsroot.enable = lib.mkOption {
      default = false;
      description = "enable Tmpfs root fs";
    };
    tmpfsroot.impermanence = lib.mkEnableOption "impermanence";
    tmpfsroot.nixstore = lib.mkOption {
      type = lib.types.attrs;
      description = "mount point of the nixos store";
    };
    tmpfsroot.home = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "mount point of home partion/fs";
    };
    tmpfsroot.boot = lib.mkOption {
      type = lib.types.attrs;
      description = "file system of boot partition (esp)";
    };
  };
  config = lib.mkIf config.tmpfsroot.enable {
    fileSystems =
      {
        "/" = {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [
            "noexec"
            "mode=755"
          ];
        };
        "/tmp" = {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [
            "defaults"
            "mode=755"
          ];
        };
        "/nix" = config.tmpfsroot.nixstore;
        #umask to close potential security hole of stored inital seed
        "/boot" = lib.mkMerge [
          config.tmpfsroot.boot
          { options = [ "umask=0077" ]; }
        ];
      }
      // lib.attrsets.optionalAttrs (config.tmpfsroot.home != null) {
        "/home" = config.tmpfsroot.home;
      };
    sops.age.keyFile = lib.mkForce "/nix/persist/system/var/lib/sops-nix/key.txt";
    programs.fuse.userAllowOther = true;
  };
}
