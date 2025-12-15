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
      default = (import ./wrapper.nix { inherit pkgs inputs; }).wrapper;
    };
  };
}
