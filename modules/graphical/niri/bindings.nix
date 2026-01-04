{
  lib,
  pkgs,
  config,
}:
{

  "XF86AudioMute".spawn = [
    "${pkgs.swayosd}/bin/swayosd-client"
    "--output-volume=mute-toggle"
  ];
  "XF86AudioMicMute".spawn = [
    "${pkgs.swayosd}/bin/swayosd-client"
    "--input-volume=mute-toggle"
  ];

  "XF86AudioRaiseVolume".spawn = [
    "${pkgs.swayosd}/bin/swayosd-client"
    "--output-volume=raise"
  ];
  "XF86AudioLowerVolume".spawn = [
    "${pkgs.swayosd}/bin/swayosd-client"
    "--output-volume=lower"
  ];

  "XF86MonBrightnessUp".spawn = [
    "${pkgs.swayosd}/bin/swayosd-client"
    "--brightness=raise"
  ];
  "XF86MonBrightnessDown".spawn = [
    "${pkgs.swayosd}/bin/swayosd-client"
    "--brightness=lower"
  ];

  "Mod+Print".screenshot-window = null;
  "Mod+Shift+S".screenshot = null;

  "Mod+Shift+i".spawn = [
    "sh"
    "-c"
    "${pkgs.wl-clipboard-rs}/bin/wl-paste|${lib.getExe pkgs.qrencode} -o -|${lib.getExe pkgs.swayimg} - --auto-zoom"
  ];

  "Mod+Shift+L".spawn = [ (lib.getExe config.programs.gtklock.package) ];

  "Mod+P".spawn = lib.getExe config.graphical.launcher;
  "Mod+Shift+T".spawn = [
    "alacritty"
    "msg"
    "create-window"
  ];

  "Mod+Shift+J".close-window = null;

  "Mod+G".switch-preset-column-width = null;
  "Mod+Shift+G".switch-preset-window-height = null;
  "Mod+Ctrl+R".reset-window-height = null;
  "Mod+F".maximize-column = null;
  "Mod+Shift+F".fullscreen-window = null;
  "Mod+Space".toggle-window-floating = null;

  "Mod+Shift+Ctrl+H".consume-window-into-column = null;
  "Mod+Shift+Ctrl+N".expel-window-from-column = null;
  "Mod+C".center-window = null;
  "Mod+Tab".switch-focus-between-floating-and-tiling = null;

  "Mod+Minus".set-column-width = "-10%";
  "Mod+Plus".set-column-width = "+10%";
  "Mod+Shift+Plus".set-window-height = "-10%";
  "Mod+Shift+Minus".set-window-height = "+10%";

  "Mod+H".focus-column-or-monitor-left = null;
  "Mod+N".focus-column-or-monitor-right = null;
  "Mod+Ctrl+H".focus-monitor-left = null;
  "Mod+Ctrl+N".focus-monitor-right = null;
  "Mod+D".focus-window-or-workspace-down = null;
  "Mod+R".focus-window-or-workspace-up = null;
  "Mod+Home".focus-column-first = null;
  "Mod+End".focus-column-last = null;
  "Mod+Shift+Home".move-column-to-first = null;
  "Mod+Shift+End".move-column-to-last = null;

  "Mod+Shift+H".move-column-left-or-to-monitor-left = null;
  "Mod+Shift+N".move-column-right-or-to-monitor-right = null;
  "Mod+Shift+R".move-window-up-or-to-workspace-up = null;
  "Mod+Shift+D".move-window-down-or-to-workspace-down = null;
}
#workspace
// builtins.foldl' (acc: elem: acc // elem) { } (
  map (i: {
    "Mod+${builtins.toString i}".focus-workspace = i;
    "Mod+Ctrl+${builtins.toString i}".move-column-to-workspace = i;
  }) (lib.genList (x: x) 10)
)
