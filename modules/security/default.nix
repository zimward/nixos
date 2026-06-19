{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [ inputs.run0-sudo-shim.nixosModules.default ];
  config = {
    security.polkit = {
      enable = true;
      adminIdentities = [ "unix-user:${config.mainUser.userName}" ];
      persistentAuthentication = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" && subject.active ${
            lib.optionalString (config.device.class == "desktop") "&& subject.local"
          }) {
            return polkit.Result.AUTH_ADMIN_KEEP;
          }
        });
      '';
    };
    security.run0-sudo-shim.enable = true;
    security.run0-sudo-shim.package = pkgs.run0-sudo-shim;
    security.apparmor = {
      enableCache = true;
      packages = [ pkgs.apparmor-profiles ];
    };
  };
}
