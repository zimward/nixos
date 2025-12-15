{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  alacritty = import ./wrapper.nix {
    inherit
      pkgs
      config
      lib
      inputs
      ;
  };
in
{
  config = lib.mkIf config.graphical.enable {
    environment.systemPackages = [ alacritty.wrapper ];
  };
}
