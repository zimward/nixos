{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    cli.applications.enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable default cli applications";
    };
  };
  config = lib.mkIf config.cli.applications.enable {
    environment.systemPackages = with pkgs; [
      unzip
      dig
    ];

  };
}
