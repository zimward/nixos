{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    motd.enable = lib.mkEnableOption "Message of the day";
  };
  config = lib.mkIf config.motd.enable {
    environment.systemPackages = [ pkgs.fortune-kind ];
    cli.nushell.extraConfig = ''
      fortune
    '';
  };
}
