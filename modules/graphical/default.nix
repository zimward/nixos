{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    graphical.enable = lib.mkOption {
      default = config.device.class == "desktop";
      description = "enable graphical applications";
    };
    graphical.background = lib.mkOption {
      default = import ./background.nix { inherit (pkgs) fetchurl; };
      description = "background image";
    };
  };
  imports = [
    ./applications.nix
    ./alacritty.nix
    ./fonts.nix
    ./ime.nix
    ./kicad.nix
    ./matlab.nix
    ./steam.nix
    ./sway
    ./niri
    ./waybar
    ./launcher.nix
    ./locker.nix
  ];
  config = {
    #running ssh agent on graphical hosts is most often needed
    systemd.user.services.ssh-agent = {
      enable = true;
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${config.programs.ssh.package}/bin/ssh-agent -D -a %t/ssh-agent";
      };
      description = "SSH authentication agent";
    };
    devel = {
      helix.enable = config.graphical.enable;
      git.enable = config.graphical.enable;
    };
    assertions =
      let
        cfg = config.graphical;
      in
      [
        {
          assertion = (cfg.enable == (cfg.niri.enable || cfg.sway.enable));
          message = "One window manager has to be enabled for graphical applications to work";
        }
        {
          assertion = (!cfg.enable || (cfg.niri.enable != cfg.sway.enable));
          message = "Only one window manager is supposed to be enabled at once";
        }
      ];
  };
}
