{ pkgs, ... }:
{
  environment.systemPackages = with pkgs;[
    librewolf
    libreoffice-qt
    hunspell #auto correction
    hunspellDicts.de_DE
    hunspellDicts.en_US
    keepassxc
    mpv    
  ];
}
