{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    graphical.ime.enable = lib.mkOption {
      default = false;
      description = "enable IME";
    };
  };
  config = lib.mkIf (config.graphical.enable && config.graphical.ime.enable) {
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-mozc ];
    };
    environment.sessionVariables = {
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };
  };
}
