{
  pkgs,
  lib,
  config,
  ...
}:
let
  updScript = pkgs.writeShellScriptBin "update.sh" ''
    nixos-rebuild switch --flake ${config.update.cfgRef} --use-remote-sudo
  '';
in
{
  config = lib.mkIf (config.device.class == "server") {
    environment.systemPackages = [ updScript ];
  };
}
