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
      ripgrep
      bottom # process manager
      du-dust
      sshfs
      fd
      fzf
    ];
    hm.programs.yazi.enable = true;
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
