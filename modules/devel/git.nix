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
        default = "zimward@zimward.moe";
        type = lib.types.str;
        description = "Email address used when commiting (maybe use sops and don't leak name)";
      };
      signingkey = lib.mkOption {
        default = "E22F760EE074E57A21CB17338DD29BB52C25EA09";
        type = lib.types.str;
        description = "GPG-Key Signature to be used when signing commits";
      };
    };
  };
  config =
    let
      enablePijul = config.device.class == "desktop";
      jjIntegration = pkgs.runCommand "jj-nu" { buildInputs = [ pkgs.jujutsu ]; } ''
        mkdir $out
        jj util completion nushell > $out/completions-jj.nu
      '';
    in
    lib.mkIf config.devel.git.enable {
      environment.systemPackages = [
        pkgs.git
      ]
      ++ (lib.optionals enablePijul [
        pkgs.pijul
        pkgs.jujutsu
      ]);

      hm.home.file.".config/pijul/config" = {
        enable = enablePijul;
        source =
          let
            aw = "always";
          in
          (pkgs.formats.toml { }).generate "config.toml"

            {
              colors = aw;
              pager = aw;
              author = {
                name = "zimward";
                full_name = "zimward";
                email = "zimward@zimward.moe";
                key_path = "${config.users.users.${config.mainUser.userName}.home}/.ssh/id_ed25519";
              };
              ignore_kinds = {
                rust = [
                  "target"
                  "result"
                ];
              };
            };

      };

      cli.nushell.extraConfig = lib.strings.optionalString enablePijul "use ${jjIntegration}/completions-jj.nu";
      hm.programs.jujutsu.enable = enablePijul;
      hm.programs.jujutsu.settings = {
        user = {
          name = "zimward";
          email = config.devel.git.userEmail;
        };
        signing = {
          behaviour = "own";
          backend = "gpg";
          key = config.devel.git.signingkey;
        };
        git.sign-on-push = true;
      };

      hm.programs.git = {
        enable = config.devel.git.enable;
        settings = {
          user = {
            name = config.mainUser.userName;
            email = config.devel.git.userEmail;
          };
          aliases = {
            "commit" = "commit -S";
          };
          extraConfig = {
            push.autoSetupRemote = true;
            commit = {
              gpgsign = true;
            };
            user = {
              signingkey = config.devel.git.signingkey;
            };
          };
        };
      };

    };
}
