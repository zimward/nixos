{
  pkgs,
  lib,
  config,
  ...
}:
let
  enLst = opt: lst: lib.optionals opt.enable lst;
  enPkg = opt: pkg: enLst opt [ pkg ];
  cfg = config.graphical;
in
{
  options.graphical = {
    default.applications.enable = lib.mkOption {
      default = config.device.class == "desktop";
      description = "enable default graphical applications";
    };
    minecraft.enable = lib.mkEnableOption "minecraft launcher";
    deluge.enable = lib.mkEnableOption "Deluge torrent client";
    obsidian.enable = lib.mkEnableOption "Obsidian";
    irc.enable = lib.mkEnableOption "irc";
  };
  config = lib.mkIf (config.graphical.default.applications.enable && config.graphical.enable) {
    environment.systemPackages =
      enPkg cfg.minecraft pkgs.prismlauncher
      ++ enPkg cfg.deluge pkgs.deluge
      ++ enPkg cfg.obsidian pkgs.obsidian
      ++ enPkg cfg.irc pkgs.weechat
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
        freetube
        nheko
        anki
      ]);
    #as long as nheko hasnt transitioned away from olm
    #related: https://github.com/Nheko-Reborn/nheko/issues/1786
    nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16"
    ];
    nixpkgs.allowUnfreePackages = [ "obsidian" ];
  };
}
