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
    _freetime = lib.mkOption {
      description = "programs that keep me from doing any work";
      type = lib.types.bool;
      default = true;
    };
  };
  config =
    let
      ltspice = pkgs.ltspice.overrideAttrs {
        src = pkgs.fetchurl {
          url = "https://ltspice.analog.com/software/LTspice64.msi";
          hash = "sha256-fw4z9BlkMUR/z7u+wMx6S267jn8y+HzVgDkQ9rJTQ70=";
        };
      };
    in
    lib.mkIf (config.graphical.default.applications.enable && config.graphical.enable) {
      environment.systemPackages =
        enPkg cfg.minecraft pkgs.prismlauncher
        ++ enPkg cfg.deluge pkgs.deluge
        ++ enPkg cfg.obsidian pkgs.obsidian
        ++ (with pkgs; [
          librewolf
          libreoffice-qt
          hunspell # auto correction
          hunspellDicts.de_DE
          hunspellDicts.en_US
          keepassxc
          thunderbird
          pavucontrol
          comma
          ltspice
        ])
        ++ (lib.optionals cfg._freetime (
          with pkgs;
          [
            freetube
            signal-desktop
            mpv
            mumble
          ]
        ));
      system.extraDependencies = [ ltspice.src ];
      nixpkgs.allowUnfreePackages = [
        "obsidian"
        "ltspice"
      ];
    };
}
