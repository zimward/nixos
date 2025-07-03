{
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.mainUser.userName ])
  ];
  config = {
    home-manager = {
      users.${config.mainUser.userName}.imports = [

        {
          home.username = config.mainUser.userName;
          home.homeDirectory = "/home/${config.mainUser.userName}";
          programs.home-manager.enable = true;

          home.sessionVariables = {
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME = "$HOME/.local/share";
            XDG_CACHE_HOME = "$HOME/.cache";
          };
          home.stateVersion = "23.11";
        }

      ];
    };
  };
}
