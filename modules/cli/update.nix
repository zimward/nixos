{
  pkgs,
  ...
}:
let
  updScript = pkgs.writeShellScriptBin "update.sh" ''
    cd /tmp
    git clone --depth 1 shilagit:git/nixos
    doas chown root:root -R ./nixos/
    doas nixos-rebuild switch --flake ./nixos/.
    doas rm -rf /tmp/nixos
  '';
in
{
  config = {
    environment.systemPackages = [ updScript ];
  };
}
