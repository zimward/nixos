{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.graphical.locker;
in
{
  options.graphical.locker = {
    enable = lib.mkEnableOption "GTKLocker";
  };
  config = lib.mkIf cfg.enable {
    programs.gtklock = {
      enable = true;
      modules = with pkgs; [
        gtklock-playerctl-module
        gtklock-powerbar-module
      ];
      config = {
        main = {
          idle-hide = true;
          idle-timeout = 10;
          gtk-theme = "Adwaita-dark";
        };
      };
      style = ''
        #window-box {
          color: white;
        }
        window {
          background-image: url("${config.graphical.background}");
        }
      '';
    };
    security.pam.services.gtklock = { };
  };
}
