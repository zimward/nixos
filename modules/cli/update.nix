{
  pkgs,
  ...
}:
let
  updScript = pkgs.writeShellScriptBin "update.sh" ''
    cd /tmp
    git clone --depth 1 shilagit:git/nixos
    nixos-rebuild switch --flake ./nixos/. --use-remote-sudo
    rm -rf /tmp/nixos
  '';
in
{
  config = {
    environment.systemPackages = [ updScript ];
  };
}
