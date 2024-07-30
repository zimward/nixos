{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    graphical.default.applications.enable = lib.mkOption {
      default = true;
      description = "enable default graphical applications";
    };
  };
  config = {
    environment.systemPackages =
      with pkgs;
      lib.optionals (config.graphical.default.applications.enable && config.graphical.enable) [
        librewolf
        libreoffice-qt
        hunspell # auto correction
        hunspellDicts.de_DE
        hunspellDicts.en_US
        keepassxc
        mpv
        thunderbird
        mumble
        pavucontrol
        unstable.freetube
        fractal-next
      ];
  };
}
