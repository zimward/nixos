{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  carapaceConfig = pkgs.runCommand "carapace-nushell-config.nu" { } ''
    ${lib.getExe pkgs.carapace} _carapace nushell >> "$out"
  '';
  starship = inputs.wrappers.wrapperModules.starship.apply {
    inherit pkgs;
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
  starshipConfig =
    let
      esc = s: lib.escape [ "/" ] (builtins.toString s);
    in
    pkgs.runCommand "starship-nushell-config.nu" { } ''
      ${lib.getExe starship.wrapper} init nu | sed "s/${esc starship.package}/${esc starship.wrapper}/g" >> "$out"
    '';

  nushell = inputs.wrappers.wrapperModules.nushell.apply {
    inherit pkgs;
    extraPackages = [
      pkgs.carapace
      starship.wrapper
    ];
    "config.nu".content = ''
      $env.config = {
        show_banner: false
        cursor_shape:{
          vi_insert:line
          vi_normal:underscore
        }
        edit_mode:vi
      }

      source ${./commands.nu}
      ${config.cli.nushell.extraConfig}
      source ${carapaceConfig}
      use ${starshipConfig}
    '';
  };
in
{
  options = {
    cli.nushell = {
      package = lib.mkOption {
        default = nushell.wrapper;
        readOnly = true;
      };
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
    };
  };
  config = lib.mkIf config.cli.nushell.enable {
    environment.systemPackages = [ config.cli.nushell.package ];
  };
}
