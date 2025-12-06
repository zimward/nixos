{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.devel.helix;
in
{
  options = {
    devel.helix.enable = lib.mkEnableOption "Helix editor";
    devel.helix.wrapper = lib.mkOption {
      readOnly = true;
      default = import ./wrapper.nix {
        inherit
          lib
          config
          pkgs
          inputs
          ;
      };
    };
    devel.helix.package = lib.mkOption {
      default = cfg.wrapper.wrapper;
    };
  };
  config = lib.mkIf config.devel.helix.enable {
    environment.systemPackages = [ cfg.wrapper.wrapper ];
    environment.sessionVariables = {
      EDITOR = lib.getExe (cfg.wrapper.wrapper);
    };
  };
}
