{ lib, config, ... }:
{
  options = {
    cli.ssh.enableAgent = lib.mkEnableOption "SSH Agent";
  };
  #this module depends on hm
  imports = [ ../home ];
  config = {
    hm.modules = lib.optionals config.cli.ssh.enableAgent [
      (
        { ... }:
        {
          services.ssh-agent.enable = true;
        }
      )
    ];
  };
}
