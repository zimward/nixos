{ lib, config, ... }:
{
  options = {
    graphical.enable = lib.mkOption {
      default = config.device.class == "desktop";
      description = "enable graphical applications";
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
  ];
  config = {
    #running ssh agent on graphical hosts is most often needed
    hm.services.ssh-agent.enable = true;
    devel = {
      helix.enable = true;
      git.enable = true;
      zellij.enable = true;
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
