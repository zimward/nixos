{ lib, config, ... }:
let
  # forPath = value: fn: if lib.strings.hasPrefix "/" value then (fn value) else value;
  wrap = envVars: lib.attrsets.mapAttrs (_name: value: ''"${value}"'') envVars;
in
{
  imports = [ ../../home ];
  options = {
    cli.nushell = {
      enable = lib.mkOption {
        default = true;
        type = lib.types.bool;
        description = "Enable nushell configuration";
      };
      extraConfig = lib.mkOption {
        default = "";
        type = lib.types.lines;
        description = "Extra nushell commands appended to config.nu";
      };
      starship.enable = lib.mkOption {
        default = true;
        type = lib.types.bool;
        description = "Enable Starship integration";
      };
      carapace.enable = lib.mkOption {
        default = true;
        type = lib.types.bool;
        description = "Enable carapace autocompletion";
      };
    };
  };
  config = lib.mkIf config.cli.nushell.enable {
    hm.modules = [
      (
        { ... }:
        {
          config = {
            programs.carapace = {
              enable = config.cli.nushell.carapace.enable;
              enableNushellIntegration = true;
            };

            programs.yazi.enableNushellIntegration = true;

            programs.nushell = {
              enable = true;

              extraConfig =
                ''
                  $env.config = {
                    show_banner: false
                    cursor_shape:{
                      vi_insert:line
                      vi_normal:underscore
                    }
                    edit_mode:vi
                  }
                  source ${./commands.nu}
                ''
                + config.cli.nushell.extraConfig;

              extraEnv = ''
                if  (not ($env | columns | any {|c| $c == DISPLAY })) and $env.XDG_VTNR? == "1" {
                   sway
                }
              '';
              environmentVariables = wrap config.environment.variables;
            };

            programs.starship = {
              enable = config.cli.nushell.starship.enable;
              enableNushellIntegration = true;
              enableZshIntegration = false;
              enableFishIntegration = false;
              settings = {
                format =
                  "[░▒▓](#a3aed2)"
                  + "[   ](bg:#a3aed2 fg:#090c0c)"
                  + "[](bg:#769ff0 fg:#a3aed2)"
                  + "\$directory"
                  + "[](fg:#769ff0 bg:#394260)"
                  + "\$git_branch"
                  + "\$git_status"
                  + "[](fg:#394260 bg:#212736)"
                  + "\$rust"
                  + "[](fg:#212736 bg:#1d2230)"
                  + "\$time"
                  + "[ ](fg:#1d2230)"
                  + "\n$character";
                directory = {
                  style = "fg:#e3e5e5 bg:#769ff0";
                  format = "[ $path ]($style)";
                  truncation_length = 3;
                  truncation_symbol = "…/";
                };
                rust = {
                  symbol = "";
                  style = "bg:#212736";
                  format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
                };
                git_status = {
                  style = "bg:#394260";
                  format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
                };
                git_branch = {
                  symbol = "";
                  style = "bg:#394260";
                  format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
                };
                time = {
                  disabled = false;
                  time_format = "%R";
                  style = "bg:#1d2230";
                  format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
                };
              };
            };
          };
        }
      )
    ];
  };
}
