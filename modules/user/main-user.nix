{ lib, config, pkgs, ...}:
{
  options ={
    main-user.userName = lib.mkOption {
      default = "mainuser";
      description = ''
        username
      '';
    };
  };
  config = {
    users.users.${config.main-user.userName}={
      isNormalUser = true;
      initialPassword = "password";
      description = "main user";
    };
  };
}
