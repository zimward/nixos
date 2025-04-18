{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./sway_cfg.nix ];
  options = {
    graphical.sway.enable = lib.mkEnableOption "sway";
  };
  config = lib.mkIf (config.graphical.enable && config.graphical.sway.enable) {
    cli.nushell.graphical_startup = "sway";
    environment.systemPackages = with pkgs; [
      alacritty
      xdg-utils
      adwaita-icon-theme
      bemenu
      mako # wayland notification service
    ];
    services.dbus = {
      enable = true;
      apparmor = "enabled";
    };
    xdg.portal = {
      enable = true;
      wlr.enable = true;
    };

    programs.sway.enable = true;

    environment.variables = {
      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = 1;
      MOZ_ENABLE_WAYLAND = 1;
    };

    services.xserver.xkb.layout = "de";
    services.xserver.xkb.variant = "dvorak";
  };
}
