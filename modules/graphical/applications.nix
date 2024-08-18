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
      default = true;
      description = "enable default graphical applications";
    };
    ereader.enable = lib.mkEnableOption "E-Book reader";
    minecraft.enable = lib.mkEnableOption "minecraft launcher";
    deluge.enable = lib.mkEnableOption "Deluge torrent client";
    obsidian.enable = lib.mkEnableOption "Obsidian";
    irc.enable = lib.mkEnableOption "irc";
  };
  config = lib.mkIf (config.graphical.default.applications.enable && config.graphical.enable) {
    environment.systemPackages =
      enPkg cfg.ereader pkgs.bookworm
      ++ enPkg cfg.minecraft pkgs.prismlauncher
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
        fractal-next
        freetube
      ]);
    nixpkgs.allowUnfreePackages = enLst cfg.obsidian [ "obsidian" ];
  };
}
