{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    graphical.ime = lib.mkOption {
      default = false;
      description = "enable IME";
    };
  };
  config = lib.mkIf (config.graphical.enable && config.graphical.ime) {
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-mozc ];
    };
  };
}
