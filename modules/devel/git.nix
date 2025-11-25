{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  jj = inputs.wrappers.wrapperModules.jujutsu.apply {
    inherit pkgs;
    settings = {
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
  };
in
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
      enableJJ = config.device.class == "desktop";
      jjIntegration = pkgs.runCommand "jj-nu" { buildInputs = [ pkgs.jujutsu ]; } ''
        mkdir $out
        jj util completion nushell > $out/completions-jj.nu
      '';
    in
    lib.mkIf config.devel.git.enable {
      environment.systemPackages = [
        pkgs.git
      ]
      ++ (lib.optionals enableJJ [
        jj.wrapper
      ]);
      cli.nushell.extraConfig = lib.strings.optionalString enableJJ "use ${jjIntegration}/completions-jj.nu";
    };
}
