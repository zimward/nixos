{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    graphical.steam.enable = lib.mkOption {
      default = false;
      description = "enable steam";
    };
  };
  imports = [ ../misc/unfree.nix ];

  config = lib.mkIf (config.graphical.enable && config.graphical.steam.enable) {
    nixpkgs.allowUnfreePackages = [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    programs.gamescope.enable = true;
    programs.gamescope.package = pkgs.gamescope.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "ValveSoftware";
        repo = "gamescope";
        rev = "1faf7acd90f960b8e6c816bfea15f699b70527f9";
        fetchSubmodules = true;
        hash = "sha256-/JMk1ZzcVDdgvTYC+HQL09CiFDmQYWcu6/uDNgYDfdM=";
      };
    };
  };
}
