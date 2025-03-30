{ config, lib, ... }:
{
  options.graphical.waybar.enable = lib.mkEnableOption "waybar";
  config = lib.mkIf config.graphical.waybar.enable {
    hm.modules = [
      (
        { ... }:
        {
          imports = [
            ./settings.nix
            # ./style.nix
          ];
          programs.waybar.enable = true;
        }
      )
    ];
  };
}
