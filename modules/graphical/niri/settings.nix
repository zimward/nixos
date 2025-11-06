{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./bindings.nix
    ./rules.nix
  ];
  options.graphical.niri.enable = lib.mkEnableOption "Niri window manager";
  config = lib.mkIf config.graphical.niri.enable {
    hm.programs.niri.settings = {
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
        focus-follows-mouse.enable = true;
        warp-mouse-to-focus.enable = true;
        workspace-auto-back-and-forth = true;
      };
      screenshot-path = "~/Screenshots/Screenshot-from-%Y-%m-%d-%H-%M-%S.png";

      spawn-at-startup =
        let
          command = cmd: { command = lib.lists.flatten [ cmd ]; };
        in
        [
          (command (lib.getExe pkgs.waybar))
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

      workspaces = {
        "com" = {
          open-on-output = "DP-3";
        };
        "games" = {
          open-on-output = "DP-3";
        };
        "browser-l" = {
          open-on-output = "DP-3";
        };
        "browser-r" = {
          open-on-output = "DP-1";
        };
      };

      layout = {
        focus-ring.enable = false;
        border = {
          enable = true;
          width = 3;
          active.color = "#f5c2e7";
          inactive.color = "#313244";
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
        theme = "miku-cursor";
        hide-when-typing = true;
        size = 16;

      };
      prefer-no-csd = true;

      overview.zoom = 0.25;

      switch-events.lid-close.action.spawn = [ (lib.getExe config.programs.gtklock.package) ];

      hotkey-overlay.skip-at-startup = true;
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
    };
    hm.services.swayosd.enable = true;
    #provided by keepassxc
    hm.services.gnome-keyring.enable = lib.mkForce false;
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      (pkgs.callPackage ../miku-cursors.nix { })
    ];
    programs.niri.enable = true;
    programs.niri.package = pkgs.callPackage ./package-git.nix { };
    niri-flake.cache.enable = false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;

    xdg.portal = {
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    services.displayManager = {
      enable = true;
      autoLogin = {
        user = config.mainUser.userName;
        enable = true;
      };
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    graphical.waybar.enable = true;
  };
}
