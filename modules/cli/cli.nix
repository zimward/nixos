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
      ripgrep
      bottom # process manager
      du-dust
      sshfs
      fd
      fzf
    ];
    #rarely needed on servers
    hm.programs.yazi.enable = config.graphical.enable;
    hm.programs.yazi.package = (
      pkgs.yazi.override {
        optionalDeps = with pkgs; [
          ripgrep
          fd
          fzf
        ];
      }
    );
  };
}
