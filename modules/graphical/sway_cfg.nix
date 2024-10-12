{
  pkgs,
  lib,
  config,
  ...
}:
let
  status_cfg = pkgs.writeText "configuration.toml" ''
    [[block]]
    block = "battery"
    format = " $icon $percentage "
    missing_format = ""

    [[block]]
    block = "cpu"

    [[block]]
    block = "memory"

    [[block]]
    block = "time"
    format = "$timestamp.datetime(f:'%Y.%m.%d %a曜日 %H:%M:%S',l:ja_JP)"
    interval = 1
  '';
  shell = lib.optionalString config.cli.nushell.enable "-e '${lib.getExe pkgs.nushell}'";
in
{
  hm.modules = [
    (
      { ... }:
      {
        config = lib.mkIf (config.graphical.enable && config.graphical.sway.enable) {
          wayland.windowManager.sway = {
            enable = true;
            package = null;
            config = rec {
              modifier = "Mod4";
              terminal = "${pkgs.alacritty}/bin/alacritty";
              menu = "bemenu-run";
              up = "r";
              down = "d";
              left = "n";
              right = "s";
              startup = lib.optionals config.graphical.ime.enable [ { command = "fcitx5 -d"; } ];
              bars = [
                {
                  position = "top";
                  statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${status_cfg}";
                }
              ];
              input = {
                "type:keyboard" = {
                  xkb_layout = "de,de";
                  xkb_variant = "dvorak,";
                  xkb_numlock = "enabled";
                };
              };
              output = {
                "DP-1" = {
                  position = "0 +1920";
                };
              };
              keybindings = {
                "${modifier}+Shift+t" = "exec (${terminal} msg create-window ${shell}) || ${terminal} ${shell}";
                "${modifier}+p" = "exec ${menu}";
                "${modifier}+Shift+j" = "kill";
                "${modifier}+BackSpace" = "input type:keyboard xkb_switch_layout next";

                "${modifier}+j" = ''exec ${lib.getExe pkgs.slurp} |${lib.getExe pkgs.grim} -g - - | ${lib.getExe pkgs.curl} -4 -X POST https://arcu.dyndns.org/imgserv/upload --data-binary @- | ${pkgs.wl-clipboard-rs}/bin/wl-copy'';
                "${modifier}+Print" = ''exec ${lib.getExe pkgs.grim} - | ${lib.getExe pkgs.curl} -4 -X POST https://arcu.dyndns.org/imgserv/upload --data-binary @- | ${pkgs.wl-clipboard-rs}/bin/wl-copy'';
                "${modifier}+Shift+i" = "exec ${pkgs.wl-clipboard-rs}/bin/wl-paste|${lib.getExe pkgs.qrencode} -o -|${lib.getExe pkgs.feh} - --auto-zoom";
                "${modifier}+Shift+y" = "exec swaymsg output DP-1 transform 90 clockwise";

                "${modifier}+${left}" = "focus left";
                "${modifier}+${down}" = "focus down";
                "${modifier}+${up}" = "focus up";
                "${modifier}+${right}" = "focus right";

                "${modifier}+Left" = "focus left";
                "${modifier}+Down" = "focus down";
                "${modifier}+Up" = "focus up";
                "${modifier}+Right" = "focus right";

                "${modifier}+Shift+${left}" = "move left";
                "${modifier}+Shift+${down}" = "move down";
                "${modifier}+Shift+${up}" = "move up";
                "${modifier}+Shift+${right}" = "move right";

                "${modifier}+Shift+Left" = "move left";
                "${modifier}+Shift+Down" = "move down";
                "${modifier}+Shift+Up" = "move up";
                "${modifier}+Shift+Right" = "move right";

                "${modifier}+b" = "splith";
                "${modifier}+m" = "splitv";
                "${modifier}+f" = "fullscreen toggle";
                "${modifier}+a" = "focus parent";

                "${modifier}+w" = "layout stacking";
                "${modifier}+v" = "layout tabbed";
                "${modifier}+e" = "layout toggle split";

                "${modifier}+Shift+space" = "floating toggle";
                "${modifier}+space" = "focus mode_toggle";

                "${modifier}+1" = "workspace number 1";
                "${modifier}+2" = "workspace number 2";
                "${modifier}+3" = "workspace number 3";
                "${modifier}+4" = "workspace number 4";
                "${modifier}+5" = "workspace number 5";
                "${modifier}+6" = "workspace number 6";
                "${modifier}+7" = "workspace number 7";
                "${modifier}+8" = "workspace number 8";
                "${modifier}+9" = "workspace number 9";

                "${modifier}+Shift+1" = "move container to workspace number 1";
                "${modifier}+Shift+2" = "move container to workspace number 2";
                "${modifier}+Shift+3" = "move container to workspace number 3";
                "${modifier}+Shift+4" = "move container to workspace number 4";
                "${modifier}+Shift+5" = "move container to workspace number 5";
                "${modifier}+Shift+6" = "move container to workspace number 6";
                "${modifier}+Shift+7" = "move container to workspace number 7";
                "${modifier}+Shift+8" = "move container to workspace number 8";
                "${modifier}+Shift+9" = "move container to workspace number 9";

                "${modifier}+Shift+minus" = "move scratchpad";
                "${modifier}+minus" = "scratchpad show";

                "${modifier}+i" = "mode resize";
              };
            };
          };
        };
      }
    )
  ];
}
