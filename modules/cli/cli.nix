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
    environment.systemPackages =
      with pkgs;
      [
        nushell
        starship
        ripgrep
        bottom # process manager
        dust
        sshfs
        fd
        fzf
      ]
      ++
        #rarely needed on servers
        lib.optionals (config.device.class == "desktop") [
          (pkgs.yazi.override {
            optionalDeps = with pkgs; [
              ripgrep
              fd
              fzf
            ];
          })
        ];
  };
}
