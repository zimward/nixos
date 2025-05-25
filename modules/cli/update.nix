{
  pkgs,
  lib,
  config,
  ...
}:
let
  updScript = pkgs.writeShellScriptBin "update.sh" ''
    nixos-rebuild switch --flake ${config.updateScript.cfgRef} --use-remote-sudo
  '';
in
{
  options = {
    updateScript.cfgRef = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "git+ssh://git@zimward.moe/~/nixos";
      description = "reference to nix flake";
    };
  };
  config = lib.mkIf (config.device.class == "server") {
    environment.systemPackages = [ updScript ];
  };
}
