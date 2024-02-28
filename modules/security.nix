{ pkgs, libs, ...}:
{
  security.polkit.enable = true;
  security.apparmor = {
    enable = true;
    enableCache = true;
    packages = [ pkgs.apparmor-profiles ];
  };
}
