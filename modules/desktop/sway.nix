{ config, pkgs, lib, ... }:

let
  #propagate sway env vars
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;
    
    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';    
  };
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'palenight'
    '';
  };
  in
  {
    environment.systemPackages = with pkgs;[
      alacritty
      dbus
      dbus-sway-environment
      configure-gtk
      xdg-utils
      glib
      palenight-theme
      gnome3.adwaita-icon-theme
      grim #screenshot
      slurp #screenshot
      wl-clipboard
      bemenu
      mako
    ];
    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals [ pkgs.xdg-desktop-portal-gtk ];
    };
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  }
