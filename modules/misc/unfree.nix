{ lib, config, ... }:
{
  options = {
    nixpkgs.allowUnfreePackages = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "List of unfree packages, due to them not beeing merged";
    };
  };
  config = {
    nixpkgs.config.allowUnfreePredicate =
      pkg: builtins.elem (lib.getName pkg) config.nixpkgs.allowUnfreePackages;
  };
}
