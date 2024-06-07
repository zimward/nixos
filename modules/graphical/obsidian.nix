{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    graphical.obsidian.enable = lib.mkOption {
      default = true;
      description = "Enable Obsidian";
    };
  };

  imports = [../unfree.nix];

  config = lib.mkIf (config.graphical.enable && config.graphical.obsidian.enable) {
    nixpkgs.allowUnfreePackages = ["obsidian"];
    environment.systemPackages = with pkgs; [obsidian];
  };
}
