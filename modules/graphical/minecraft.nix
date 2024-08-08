{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.graphical;
in
{
  options.graphical.minecraft.enable = lib.mkEnableOption "minecraft launcher";
  config = lib.mkIf (cfg.enable && cfg.minecraft.enable) {
    environment.systemPackages = [ pkgs.prismlauncher ];
  };
}
