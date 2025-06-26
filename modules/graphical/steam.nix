{
  config,
  lib,
  ...
}:
{
  options = {
    graphical.steam.enable = lib.mkOption {
      default = false;
      description = "enable steam";
    };
  };
  imports = [ ../misc/unfree.nix ];

  config = lib.mkIf (config.graphical.enable && config.graphical.steam.enable) {
    nixpkgs.allowUnfreePackages = [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    programs.gamescope.enable = true;
  };
}
