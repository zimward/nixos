{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    main-user.userName = lib.mkOption {
      default = "mainuser";
      description = ''
        username
      '';
    };
    main-user.hashedPassword = lib.mkOption {
      default = null;
      description = "hashed password of main user";
    };
  };
  config = {
    users.users.${config.main-user.userName} = {
      isNormalUser = true;
      initialPassword = lib.mkIf (config.main-user.hashedPassword == null) "password";
      hashedPassword = config.main-user.hashedPassword;
      description = "main user";
      shell = pkgs.nushell;
    };
  };
}
