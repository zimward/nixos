{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ../home ];
  options = {
    devel.zellij.enable = lib.mkEnableOption "zelji terminal multiplexer";
  };
  config = lib.mkIf config.devel.zellij.enable {
    hm.modules = [
      (
        { ... }:
        {

          programs.zellij = {
            enable = true;
            settings = {
              default_shell = "${pkgs.nushell}/bin/nu";
              keybinds = {
                pane = {
                  "bind \"h\"" = {
                    MoveFocus = "Left";
                  };
                  "bind \"n\"" = {
                    MoveFocus = "Right";
                  };
                  "bind \"d\"" = {
                    MoveFocus = "Down";
                  };
                  "bind \"r\"" = {
                    MoveFocus = "Up";
                  };
                };
              };
            };
          };
        }
      )
    ];
  };
}
