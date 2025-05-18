{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    devel.latex = lib.mkOption {
      default = false;
      description = "Enable TexLive";
    };
  };
  config = lib.mkIf config.devel.latex { environment.systemPackages = with pkgs; [ texliveFull ]; };
}
