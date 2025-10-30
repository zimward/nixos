{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  options = {
    graphical.launcher = lib.mkOption {
      type = lib.types.unspecified;
      description = "launcher to use";
      default =
        (inputs.wrappers.wrapperModules.fuzzel.apply {
          inherit pkgs;
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
        }).wrapper;
    };
  };
}
