{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = {
    security.polkit = {
      enable = true;
      adminIdentities = [ "unix-user:${config.mainUser.userName}" ];
      settings.Polkitd.ExpirationSeconds = 10 * 60;
    };
    security.sudo.enable = false;

    security.run0 = {
      enable = true;
      enableSudoAlias = true;
      persistentAuth.enable = true;
      persistentAuth.enableRemote = config.device.class != "desktop";
    };

    security.apparmor = {
      enableCache = true;
      packages = [ pkgs.apparmor-profiles ];
    };
    security.account-utils.enable = true;
    #only on desktops setuid is still needed for fusermount3
    security.enableWrappers = config.device.class == "desktop";
    security.wrappers = lib.listToAttrs (
      map
        (name: {
          inherit name;
          value = {
            enable = false;
          };
        })
        [
          "mount"
          "newgrp"
          "qemu-bridge-helper"
          "sg"
          "spice-client-glib-usb-acl-helper"
          "su"
          "umount"
        ]
    );
  };
}
