{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    mainUser.userName = lib.mkOption {
      default = "mainuser";
      description = ''
        username
      '';
      type = lib.types.nonEmptyStr;
    };
    mainUser.hashedPassword = lib.mkOption {
      default = null;
      description = "hashed password of main user";
    };
  };
  config = {
    users.users.${config.mainUser.userName} = {
      isNormalUser = true;
      initialPassword = lib.mkIf (config.mainUser.hashedPassword == null) "password";
      hashedPassword = config.mainUser.hashedPassword;
      description = "benevolent dictator for life";
      shell = pkgs.nushell;
    };
  };
}
