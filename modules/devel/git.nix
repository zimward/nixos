{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    devel.git = {
      enable = lib.mkEnableOption "git";
      userEmail = lib.mkOption {
        default = "96021122+zimward@users.noreply.github.com";
        type = lib.types.str;
        description = "Email address used when commiting (maybe use sops and don't leak name)";
      };
      signingkey = lib.mkOption {
        default = "CBF7FA5EF4B58B6859773E3E4CAC61D6A482FCD9";
        type = lib.types.str;
        description = "GPG-Key Signature to be used when signing commits";
      };
    };
  };
  config = lib.mkIf config.devel.git.enable {
    environment.systemPackages = [ pkgs.git ];
    hm.modules = [
      (
        { ... }:
        {
          programs.git = {
            enable = config.devel.git.enable;
            userName = config.main-user.userName;
            userEmail = config.devel.git.userEmail;
            aliases = {
              "commit" = "commit -S";
            };
            extraConfig = {
              push.autoSetupRemote = true;
              commit = {
                gpgsign = true;
              };
              safe = {
                directory = "/etc/nixos/";
              };
              user = {
                signingkey = config.devel.git.signingkey;
              };
            };
          };
        }
      )
    ];
  };
}
