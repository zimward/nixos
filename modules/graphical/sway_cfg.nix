{pkgs, config, lib, ...}:
let
  status_cfg = import ./status_cfg.nix {inherit pkgs config;};
in
{
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "nu -c bemenu-run | xargs swaymsg exec --";
      startup = [
        {command = "dbus-sway-environment";}
        {command = "configure-gtk";}
      ];
      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${status_cfg}";
         # swaybarCommand = "${pkgs.waybar}/bin/waybar"; maybe configure waybar
        }
      ];
      input = {
        "type:keyboard" = {xkb_layout = "de,de"; xkb_variant = "dvorak,"; xkb_numlock="enabled";};
      };
      keybindings = lib.mkOptionDefault {
        "${modifier}+Shift+t" = "exec ${terminal}";
        "${modifier}+p" = "exec ${menu}";
        "${modifier}+BackSpace" = "input type:keyboard xkb_switch_layout next";
      };
    };
  };
}
