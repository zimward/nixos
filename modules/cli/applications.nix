{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.cli.applications.enable = lib.mkEnableOption "default cli applications";
  config = lib.mkIf config.cli.applications.enable {
    environment.systemPackages = with pkgs; [
      unzip
      dig
    ];

  };
}
