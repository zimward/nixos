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
  config = lib.mkIf config.graphical.steam.enable {
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
