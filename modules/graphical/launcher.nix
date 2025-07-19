{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    graphical.launcher = lib.mkOption {
      type = lib.types.package;
      description = "launcher to use";
      default = pkgs.fuzzel;
    };
  };
  config = lib.mkIf config.graphical.enable {
    hm.programs.fuzzel = {
      enable = true;
      package = config.graphical.launcher;
      settings = {
        main = {
          anchor = "top";
          layer = "overlay";
        };
        colors = {
          #apparently fuzzel wants an alpha channel too?
          background = "1a1b26ff";
          text = "a9b1d6ff";
        };
      };
    };
  };
}
