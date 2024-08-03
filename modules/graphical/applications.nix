{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable { system = config.nixpkgs.hostPlatform.system; };
in
{
  options = {
    graphical.default.applications.enable = lib.mkOption {
      default = true;
      description = "enable default graphical applications";
    };
  };
  config = lib.mkIf (config.graphical.default.applications.enable && config.graphical.enable) {
    environment.systemPackages =
      [ unstable.pkgs.freetube ]
      ++ (with pkgs; [
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
        fractal-next
      ]);
  };
}
