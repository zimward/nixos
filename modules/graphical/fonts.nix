{pkgs,...}:
{
  fonts={
    packages = with pkgs;[
      noto-fonts
      noto-fonts-cjk
      liberation_ttf
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
    fontDir.enable = true;
  };

}
