{ pkgs, config, ... }:
{
  fonts = {
    packages =
      with pkgs;
      lib.optionals config.graphical.enable [
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
