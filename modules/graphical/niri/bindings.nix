{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.graphical.niri.enable {
  hm.programs.niri.settings.binds =
    with config.hm.lib.niri.actions;
    {
      "XF86AudioMute".action = spawn "swayosd-client" "--output-volume=mute-toggle";
      "XF86AudioMicMute".action = spawn "swayosd-client" "--input-volume=mute-toggle";

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

      "Mod+P".action.spawn = lib.getExe config.graphical.launcher;
      "Mod+Shift+T".action.spawn = [
        (lib.getExe pkgs.alacritty)
        "msg"
        "create-window"
      ];

      "Mod+Shift+J".action.close-window = [ ];
      "Mod+Y".action.spawn = [
        (lib.getExe config.hm.programs.niri.package)
        "msg"
        "output"
        "DP-3"
        "transform"
        "90"
      ];
      "Mod+Shift+Y".action.spawn = [
        (lib.getExe config.hm.programs.niri.package)
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
    }
    #workspace actions
    // builtins.foldl' (acc: elem: acc // elem) { } (
      map (i: {
        "Mod+${builtins.toString i}".action.focus-workspace = i;
        "Mod+Ctrl+${builtins.toString i}".action.move-column-to-workspace = i;
      }) (lib.genList (x: x) 10)
    );
}
