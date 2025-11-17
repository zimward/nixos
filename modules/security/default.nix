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
    };
    security.run0-sudo-shim.enable = true;
    security.apparmor = {
      enableCache = true;
      packages = [ pkgs.apparmor-profiles ];
    };
  };
}
