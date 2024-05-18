{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    latex = lib.mkOption {
      default = false;
      description = "Enable TexLive";
    };
  };
  config = lib.mkIf config.latex {
    environment.systemPackages = with pkgs; [
      texliveFull
    ];
  };
}
