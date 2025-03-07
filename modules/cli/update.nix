{
  pkgs,
  lib,
  config,
  ...
}:
let
  path = lib.lists.last (lib.strings.splitString "/" config.updateScript.cfgRef);
  updScript = pkgs.writeShellScriptBin "update.sh" ''
    cd /tmp
    git clone --depth 1 ${config.updateScript.cfgRef}
    nixos-rebuild switch --flake ./${path}/. --use-remote-sudo
    rm -rf /tmp/${path}
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
