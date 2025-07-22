{ pkgs, ... }:
{
  security.polkit.enable = true;
  security.apparmor = {
    enableCache = true;
    packages = [ pkgs.apparmor-profiles ];
  };
}
