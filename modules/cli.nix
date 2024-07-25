{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    cli.enable = lib.mkOption {
      default = true;
      description = "enable standart cli applications";
    };
  };
  config = lib.mkIf config.cli.enable {
    environment.systemPackages = with pkgs; [
      nushell
      starship
      helix
      yazi # file manager
      ripgrep
      bottom # process manager
      du-dust
      sshfs
    ];
  };
}
