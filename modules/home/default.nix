{
  lib,
  inputs,
  config,
  ...
}:
{
  options = {
    hm = {
      modules = lib.mkOption {
        default = [ ];
        type = with lib.types; listOf raw;
        description = "Modules to be included by home manager";
      };
      stateVersion = lib.mkOption {
        default = "23.11";
        type = lib.types.str;
        description = "State Version of home-manager. DON'T CHANGE UNLESS NESSESAIRY!";
      };
    };
  };
  config = {
    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
        syscfg = config;
      };
      users.${config.main-user.userName}.imports = [
        (
          { ... }:
          {
            home.username = config.main-user.userName;
            home.homeDirectory = "/home/${config.main-user.userName}";
            programs.home-manager.enable = true;

            home.sessionVariables = {
              XDG_CONFIG_HOME = "$HOME/.config";
              XDG_DATA_HOME = "$HOME/.local/share";
              XDG_CACHE_HOME = "$HOME/.cache";
            };
            home.stateVersion = config.hm.stateVersion;
          }
        )
      ] ++ config.hm.modules;
    };
  };
}
