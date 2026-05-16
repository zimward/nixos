{ lib, ... }:
{
  imports = [
    ./matrix.nix
    ./livekit.nix
  ];
  options = {
    services.matrix = {
      fqdn = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "matrix.zimward.moe";
      };
      clientConfig = lib.mkOption {
        type = lib.types.attrs;
        default = { };
      };
    };
  };
}
