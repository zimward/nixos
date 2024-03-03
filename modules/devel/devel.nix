{ pkgs, ... }:
{
  environment.systemPackages = with pkgs;[
    git
    rustup
    gcc_multi
  ];
}
