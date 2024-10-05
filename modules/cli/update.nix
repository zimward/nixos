{
  pkgs,
  config,
  ...
}:
let
  updScript = pkgs.writeShellScriptBin "update.sh" ''
    #!${pkgs.stdenv.shell}
    cd /tmp
    git clone --depth 1 shilagit:git/nixos
    doas nixos-rebuild switch --flake ./nixos/.
    rm -rf nixos
  '';
in
{
  config = {
    environment.systemPackages = [ updScript ];
  };
}
