{lib, ...}: {
  options = {
    graphical.enable = lib.mkOption {
      default = true;
      description = "enable graphical applications";
    };
  };
  imports = [
    ./fonts.nix
    ./applications.nix
    ./sway.nix
    ./ime.nix
  ];
}
