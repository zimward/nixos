{ inputs, ... }:
{
  imports = [
    inputs.niri.nixosModules.niri
    ./settings.nix
  ];
}
