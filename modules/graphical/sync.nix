{ lib, config, ... }: {
  options.graphical.sync.enable = lib.mkEnableOption "syncthing";
  config = lib.mkIf config.graphical.sync.enable {
    services.syncthing =
      let
        user = config.mainUser.userName;
      in
      {
        enable = true;
        inherit user;
        dataDir = config.users.users.${user}.home + "/Dokumente/Sync";
        configDir = config.users.users.${user}.home + "/.config/syncthing";
      };
  };
}
