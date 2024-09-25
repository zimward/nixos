{ ... }:
{
  imports = [
    ./cli.nix
    ./motd.nix
    ./ssh.nix
    ./nushell
    ./applications.nix
    ./update.nix
  ];
}
