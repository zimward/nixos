{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.graphical.enable {
    hm.modules = [
      (
        { ... }:
        {
          programs.alacritty.enable = true;
          programs.alacritty.settings = {
            window.opacity = 0.3;
            terminal.shell = lib.getExe pkgs.nushell;
          };
        }
      )
    ];
  };
}
