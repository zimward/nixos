{
  pkgs,
  config,
  modulesPath,
  ...
}:
{
  disabledModules = [
    "${modulesPath}/security/run0.nix"
    "${modulesPath}/security/polkit.nix"
  ];
  imports = [
    ./polkit.nix
    ./run0.nix
  ];
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
  };
}
