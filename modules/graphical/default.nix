{
  lib,
  config,
  ...
}: {
  options = {
    enable = lib.mkOption {
      default = true;
      description = "enable graphical applications";
    };
  };
  config = lib.mkIf config.enable {
    imports = [
      ./fonts.nix
      ./applications.nix
      ./status_cfg.nix
      ./sway.nix
      ./sway_cfg.nix
    ];
  };
}
