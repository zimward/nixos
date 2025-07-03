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
      helvetica-neue-lt-std # non MS font thats almost arial, nobody should notice the difference
    ];
    fontDir.enable = true;
  };
  nixpkgs.allowUnfreePackages = [ "helvetica-neue-lt-std" ];

}
