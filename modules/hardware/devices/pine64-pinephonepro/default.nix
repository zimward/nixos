{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./kernel
    # ./firmware
  ];

  boot.kernelParams = [ "earlycon=uart8250,mmio32,0xff1a0000" ];

  # services.eg25-manager.enable = lib.mkDefault true;
}
