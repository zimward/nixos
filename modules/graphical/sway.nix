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
    environment.systemPackages = with pkgs; [
      alacritty
      xdg-utils
      adwaita-icon-theme
      grim # screenshot
      slurp # screenshot
      wl-clipboard
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
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    };

    programs.sway = {
      enable = true;
      extraSessionCommands = lib.strings.concatLines (
        [
          ''
            export SDL_VIDEODRIVER=wayland
            export QT_QPA_PLATFORM=wayland
            export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
            export _JAVA_AWT_WM_NONREPARENTING=1
            export MOZ_ENABLE_WAYLAND=1
          ''
        ]
        ++ lib.optionals config.graphical.ime.enable [ "fcitx5 -d" ]
      );
    };

    services.xserver.xkb.layout = "de";
    services.xserver.xkb.variant = "dvorak";
  };
}
