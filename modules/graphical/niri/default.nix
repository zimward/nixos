{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  niri = (
    import ./wrapper.nix {
      inherit
        lib
        pkgs
        config
        inputs
        ;
    }
  );
in
{
  options.graphical.niri = {
    enable = lib.mkEnableOption "Niri window manager";
    wrapper = lib.mkOption {
      default = niri;
    };
  };
  config = lib.mkIf config.graphical.niri.enable {
    # services.swayosd.enable = true;
    systemd.user.services.swayosd = {
      enable = true;
      serviceConfig = {
        RestartSec = 2;
        Restart = "always";
        Type = "simple";

      };
      unitConfig = {
        After = "graphical-session.target";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "Volume/backlight OSD indicator";
        Documentation = "man:swayosd(1)";
        PartOf = "graphical-session.target";
        StartLimitBurst = 5;
        StartLimitIntervalSec = 10;
      };
    };
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      (pkgs.callPackage ../miku-cursors.nix { })
    ];
    programs.niri.enable = true;
    programs.niri.package = lib.mkDefault niri.wrapper;
    #provided by keepassxc
    services.gnome.gnome-keyring.enable = false;

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
