{
  pkgs,
  config,
  lib,
  ...
}:
{
  fonts = lib.mkIf config.graphical.enable {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      liberation_ttf
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code
    ];
    fontDir.enable = true;
  };

}
