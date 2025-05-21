{
  lib,
  pkgs,
}:
{ config, ... }:
{
  programs.niri.settings.binds = with config.lib.niri.actions; {
    "XF86AudioMute".action = spawn "swayosd-client" "--output-volume=mute-toggle";
    "XF86AudioMicMute".action = spawn "swayosd-client" "--input-volume=mute-toggle";

    # "XF86AudioPlay".action = playerctl "play-pause";
    # "XF86AudioStop".action = playerctl "pause";
    # "XF86AudioPrev".action = playerctl "previous";
    # "XF86AudioNext".action = playerctl "next";

    "XF86AudioRaiseVolume".action.spawn = [
      "swayosd-client"
      "--output-volume=raise"
    ];
    "XF86AudioLowerVolume".action.spawn = [
      "swayosd-client"
      "--output-volume=lower"
    ];

    "XF86MonBrightnessUp".action.spawn = [
      "swayosd-client"
      "--brightness=raise"
    ];
    "XF86MonBrightnessDown".action.spawn = [
      "swayosd-client"
      "--brightness=lower"
    ];

    "Mod+Print".action = screenshot-window;
    "Mod+Shift+S".action = screenshot;

    "Mod+Shift+i".action.spawn = [
      "sh"
      "-c"
      "${pkgs.wl-clipboard-rs}/bin/wl-paste|${lib.getExe pkgs.qrencode} -o -|${lib.getExe pkgs.feh} - --auto-zoom"
    ];

    #upload clipboard
    "Mod+j".action.spawn = [
      "sh"
      "-c"
      "${pkgs.wl-clipboard-rs}/bin/wl-paste | ${lib.getExe pkgs.curl} -4 -X POST https://arcureid.de/imgserv/upload --data-binary @- | ${pkgs.wl-clipboard-rs}/bin/wl-copy"
    ];

    "Mod+P".action.spawn = lib.getExe pkgs.anyrun;
    "Mod+Shift+T".action.spawn =
      let
        terminal = lib.getExe pkgs.alacritty;
      in
      [
        "sh"
        "-c"
        "(${terminal} msg create-window) || ${terminal}"
      ];
    # "Ctrl+Alt+L".action = spawn "sh -c pgrep hyprlock || hyprlock";

    "Mod+Shift+J".action.close-window = [ ];
    "Mod+Y".action.spawn = [
      (lib.getExe config.programs.niri.package)
      "msg"
      "output"
      "DP-3"
      "transform"
      "90"
    ];
    "Mod+Shift+Y".action.spawn = [
      (lib.getExe config.programs.niri.package)
      "msg"
      "output"
      "DP-3"
      "transform"
      "normal"
    ];

    "Mod+G".action = switch-preset-column-width;
    "Mod+Shift+G".action = switch-preset-window-height;
    "Mod+Ctrl+R".action = reset-window-height;
    "Mod+F".action = maximize-column;
    "Mod+Shift+F".action = fullscreen-window;
    "Mod+Space".action = toggle-window-floating;

    "Mod+Shift+Ctrl+H".action = consume-window-into-column;
    "Mod+Shift+Ctrl+N".action = expel-window-from-column;
    "Mod+C".action = center-window;
    "Mod+Tab".action = switch-focus-between-floating-and-tiling;

    "Mod+Minus".action = set-column-width "-10%";
    "Mod+Plus".action = set-column-width "+10%";
    "Mod+Shift+Plus".action = set-window-height "-10%";
    "Mod+Shift+Minus".action = set-window-height "+10%";

    "Mod+H".action = focus-column-or-monitor-left;
    "Mod+N".action = focus-column-or-monitor-right;
    "Mod+Ctrl+H".action = focus-monitor-left;
    "Mod+Ctrl+N".action = focus-monitor-right;
    "Mod+D".action = focus-window-or-workspace-down;
    "Mod+R".action = focus-window-or-workspace-up;
    "Mod+Home".action = focus-column-first;
    "Mod+End".action = focus-column-last;
    "Mod+Shift+Home".action = move-column-to-first;
    "Mod+Shift+End".action = move-column-to-last;

    "Mod+Shift+H".action = move-column-left-or-to-monitor-left;
    "Mod+Shift+N".action = move-column-right-or-to-monitor-right;
    "Mod+Shift+R".action = move-window-up-or-to-workspace-up;
    "Mod+Shift+D".action = move-window-down-or-to-workspace-down;

    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;
    "Mod+Ctrl+1".action.move-column-to-workspace = 1;
    "Mod+Ctrl+2".action.move-column-to-workspace = 2;
    "Mod+Ctrl+3".action.move-column-to-workspace = 3;
    "Mod+Ctrl+4".action.move-column-to-workspace = 4;
    "Mod+Ctrl+5".action.move-column-to-workspace = 5;
    "Mod+Ctrl+6".action.move-column-to-workspace = 6;
    "Mod+Ctrl+7".action.move-column-to-workspace = 7;
    "Mod+Ctrl+8".action.move-column-to-workspace = 8;
    "Mod+Ctrl+9".action.move-column-to-workspace = 9;
  };
}
