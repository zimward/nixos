{ lib, ... }:
let
  blacklist = host: ''
    0.0.0.0 ${host}
    :: ${host}
  '';
  concat = lib.lists.foldr (a: b: a + b) "\n";
in
{
  networking.extraHosts = concat (
    map blacklist [
      "reddit.com"
      "old.reddit.com"
      "www.reddit.com"
    ]
  );
}
