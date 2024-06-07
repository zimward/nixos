{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    graphical.steam.enable = lib.mkOption {
      default = false;
      description = "enable steam";
    };
  };
  imports = [../unfree.nix];

  config = lib.mkIf (config.graphical.enable && config.graphical.steam.enable) {
    nixpkgs.allowUnfreePackages = [
      "steam"
      "steam-original"
      "steam-run"
    ];
    programs.steam.enable = true;
    programs.steam.package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
    };
    hardware.steam-hardware.enable = true;
    programs.gamescope.enable = true;
  };
}
