{
  pkgs,
  inputs,
  lib,
  config,
}:
inputs.wrappers.wrapperModules.niri.apply {
  inherit pkgs;
  settings = {
    binds = import ./bindings.nix { inherit pkgs lib config; };
    window-rules = import ./rules.nix;
    layer-rules = [
      {
        matches = [ { namespace = "^notifications$"; } ];
        block-out-from = "screen-capture";
        opacity = 0.8;
      }
    ];
    environment = {
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland,x11";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      TERM = "alacritty";
      TERMINAL = "alacritty";
      XMODIFIERS = "@im=fcitx";
    };
    input = {
      keyboard.xkb = {
        layout = "de(dvorak)";
      };
      keyboard.numlock = true;
      focus-follows-mouse = null;
      warp-mouse-to-focus = null;
      workspace-auto-back-and-forth = true;
    };
    screenshot-path = "~/Screenshots/Screenshot-from-%Y-%m-%d-%H-%M-%S.png";

    spawn-at-startup =
      let
        command = cmd: lib.lists.flatten [ cmd ];
      in
      [
        (command (lib.getExe config.graphical.waybar.package))
        (command [
          "alacritty"
          "--daemon"
        ])
        (command [
          (lib.getExe pkgs.swaybg)
          "-m"
          "fill"
          "-i"
          "${config.graphical.background}"
        ])
        (command [
          (lib.getExe pkgs.mako)
          "--default-timeout"
          "20000"
        ])
        (command "librewolf")
        (command "thunderbird")
        (command "keepassxc")
      ]
      ++ lib.optionals config.graphical.ime.enable [
        (command [
          "fcitx5"
          "-d"
          "-r"
        ])
      ];
    layout = {
      focus-ring.off = null;
      border = {
        width = 3;
        active-color = "#f5c2e7";
        inactive-color = "#313244";
      };

      preset-column-widths = [
        { proportion = 1.0; }
        { proportion = 1.0 / 2.0; }
        { proportion = 1.0 / 3.0; }
        { proportion = 1.0 / 4.0; }
      ];
      preset-window-heights = [
        { proportion = 1.0; }
        { proportion = 1.0 / 2.0; }
        { proportion = 1.0 / 3.0; }
      ];
      default-column-width = {
        proportion = 0.5 / 1.0;
      };

      gaps = 0;
      struts = {
        left = 0;
        right = 0;
        top = 0;
        bottom = 0;
      };
    };
    cursor = {
      xcursor-theme = "miku-cursor";
      xcursor-size = 16;
      hide-when-typing = true;

    };
    prefer-no-csd = true;

    overview.zoom = 0.25;

    switch-events.lid-close.spawn = [
      "sh"
      "-c"
      "${(lib.getExe config.programs.gtklock.package)} -d; sleep 3; systemctl suspend"
    ];

    hotkey-overlay.skip-at-startup = true;
    xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
  };
}
