{ pkgs }:
let
  version = "1.2.6";
in
pkgs.stdenvNoCC.mkDerivation {
  name = "miku-cursors";
  inherit version;
  src = pkgs.fetchFromGitHub {
    owner = "supermariofps";
    repo = "hatsune-miku-windows-linux-cursors";
    rev = version;
    hash = "sha256-OQjjOc9VnxJ7tWNmpHIMzNWX6WsavAOkgPwK1XAMwtE=";
  };
  buildPhase = "
    mkdir -p $out/share/icons/miku-cursor
    cp -r $src/miku-cursor-linux/* $out/share/icons/miku-cursor/
  ";
}
