{
  pkgs,
  lib,
  config,
  ...
}:
let
  updScript = pkgs.writeShellScriptBin "update.sh" ''
    cd /tmp
    git clone --depth 1 ${config.updateScript.cfgRef}
    nixos-rebuild switch --flake ./nixos/. --use-remote-sudo
    rm -rf /tmp/nixos
  '';
in
{
  options = {
    updateScript.cfgRef = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "reference to nix flake";
    };
  };
  config = lib.mkIf (config.device.class == "server") {
    environment.systemPackages = [ updScript ];
  };
}
