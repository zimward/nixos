{ lib, config, ... }:
let
  blacklist = host: ''
    0.0.0.0 ${host}
    :: ${host}
  '';
  concat = lib.lists.foldr (a: b: a + b) "\n";
in
{
  options = {
    net.filter = {
      enable = lib.mkEnableOption ''
        hostfile based domain blacklist. 
        Usefull to keep me from doomscrolling (and potenitally block tracking servers)'';
      extraDomains = lib.mkOption {
        default = [ ];
        type = with lib.types; listOf nonEmptyStr;
        description = "List of additional domains to be blacklisted.";
      };
    };
  };
  config = lib.mkIf config.net.filter.enable {
    networking.extraHosts = concat (
      map blacklist (
        [
          "reddit.com"
          "www.reddit.com"
          "pornhub.com"
          "youporn.com"
        ]
        ++ config.net.filter.extraDomains
      )
    );
  };
}
