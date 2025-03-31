{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.graphical.niri.enable = lib.mkEnableOption "Niri window manager";
  config = lib.mkIf config.graphical.niri.enable {
    hm.modules = [
      (
        { ... }:
        {
          imports = [
            (import ./bindings.nix {
              inherit
                lib
                pkgs
                ;
            })
            ./rules.nix
          ];
          programs.niri.settings = {
            environment = {
              CLUTTER_BACKEND = "wayland";
              DISPLAY = ":0";
              GDK_BACKEND = "wayland,x11";
              MOZ_ENABLE_WAYLAND = "1";
              NIXOS_OZONE_WL = "1";
              QT_QPA_PLATFORM = "wayland;xcb";
              QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
              SDL_VIDEODRIVER = "wayland";
              _JAVA_AWT_WM_NONREPARENTING = "1";
              TERM = "alacritty";
              TERMINAL = "alacritty";
              QT_IM_MODULE = "fcitx";
              # GTK_IM_MODULE = "fcitx";
              XMODIFIERS = "@im=fcitx";
            };
            input = {
              keyboard.xkb.layout = "de(dvorak)";
              focus-follows-mouse.enable = true;
              warp-mouse-to-focus = true;
              workspace-auto-back-and-forth = true;
            };
            screenshot-path = "~/Screenshots/Screenshot-from-%Y-%m-%d-%H-%M-%S.png";

            spawn-at-startup =
              let
                command = cmd: { command = [ cmd ]; };
              in
              [
                (command (lib.getExe pkgs.xwayland-satellite))
                (command (lib.getExe pkgs.waybar))
                {
                  command = [
                    (lib.getExe pkgs.swaybg)
                    "-m"
                    "fill"
                    "-i"
                    "${config.users.users.${config.main-user.userName}.home}/.bg.jpg"
                  ];
                }
                (command (lib.getExe pkgs.mako))
                (command "librewolf")
                (command "thunderbird")
                (command "keepassxc")
              ]
              ++ lib.optionals config.graphical.ime.enable [
                {
                  command = [
                    (lib.getExe pkgs.fcitx5)
                    "-d"
                  ];
                }
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
              theme = "Adwaita";
              hide-when-typing = true;
              size = 16;

            };
            prefer-no-csd = true;
            hotkey-overlay.skip-at-startup = true;
          };
          #provided by keepassxc
          services.gnome-keyring.enable = lib.mkForce false;
        }
      )
    ];
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
    ];
    programs.niri.enable = true;
    niri-flake.cache.enable = false;
    programs.niri.package = pkgs.niri;
    cli.nushell.graphical_startup = "niri";
    graphical.waybar.enable = true;
  };
}
