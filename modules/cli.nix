{
  pkgs,
  lib,
  config,
  ...
}: {
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
      htop
      helix
      joshuto #file manager
      ripgrep
      #zenith #process manager, build currently failing
      htop
      du-dust
    ];
  };
}
