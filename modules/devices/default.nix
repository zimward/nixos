{ lib, ... }:
{
  imports = [
    ./base.nix
    ./desktop.nix
    ./server.nix
  ];
  options.device.class = lib.mkOption {
    description = "Class of the device.";
    type = lib.types.enum [
      "none"
      "base"
      "server"
      "desktop"
      "mobile"
    ];
  };
}
