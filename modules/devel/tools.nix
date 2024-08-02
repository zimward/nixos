{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    devenv.enable = lib.mkOption {
      default = true;
      description = "Enable common development packages";
    };
  };
  config = lib.mkIf config.devenv.enable {
    environment.systemPackages = with pkgs; [
      rustup
      gcc_multi
      (python3.withPackages (python-pkgs: [
        python-pkgs.numpy
        python-pkgs.matplotlib
      ]))
      linuxPackages_latest.perf
    ];
  };
}
