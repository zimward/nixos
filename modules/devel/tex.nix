{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    devel.latex = lib.mkOption {
      default = config.device.class == "desktop";
      description = "Enable TexLive";
    };
  };
  config = lib.mkIf config.devel.latex { environment.systemPackages = with pkgs; [ texliveFull ]; };
}
