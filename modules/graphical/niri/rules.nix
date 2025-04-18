{ ... }:
{
  programs.niri.settings.window-rules = [
    #prevent starting applications from grabbing focus
    {
      matches = [ { app-id = ".*"; } ];
      excludes = [
        { app-id = "org.keepassxc.KeePassXC"; }
      ];
      open-focused = false;
      open-floating = false;
    }
    #disallow screencapture for keepass,etc.
    {
      matches = [
        { app-id = "org.keepassxc.KeePassXC"; }
        { app-id = "thunderbird"; }
        { app-id = "nheko"; }
      ];
      block-out-from = "screen-capture";
    }
    {
      matches = [
        { title = "^.+Zugriffsanfrage$"; }
        { title = "^Datenbank+.*$"; }
        { title = "^.+Error$"; }
        { app-id = "thunderbird"; }
        { app-id = "xdg-desktop-portal-gnome"; }
      ];
      excludes = [
        { title = "^.*Mozilla Thunderbird$"; }
      ];
      open-focused = true;
      open-floating = true;
    }
    {
      matches = [
        { app-id = "thunderbird"; }
        { app-id = "nheko"; }
      ];
      open-on-workspace = "com";
      open-on-output = "DP-3";
      default-column-width.proportion = 1.0;
    }
    {
      matches = [
        { app-id = "steam"; }
        { app-id = "org.prismlauncher.PrismLauncher"; }
      ];
      open-on-workspace = "games";
      open-on-output = "DP-3";
      default-column-width.proportion = 1.0;
    }
    #mumble proportions
    {
      matches = [
        { app-id = "info.mumble.Mumble"; }
      ];
      default-column-width.proportion = 0.18;
      default-window-height.proportion = 0.5;
      open-on-output = "DP-1";
      open-on-workspace = "browser-r";
    }
    {
      matches = [
        { app-id = "FreeTube"; }
      ];
      default-column-width.proportion = (1.0 - 0.18);
      default-window-height.proportion = 1.0;
      open-on-output = "DP-1";
      open-on-workspace = "browser-r";
    }
    {
      matches = [ { app-id = "librewolf"; } ];
      open-maximized = true;
      open-on-output = "DP-3";
      open-on-workspace = "browser-l";
    }
    {
      matches = [ { app-id = "librewolf"; } ];
      excludes = [ { title = "^.*LibreWolf$"; } ];
      open-floating = true;
      open-focused = true;
    }
  ];
  programs.niri.settings.layer-rules = [
    {
      matches = [ { namespace = "^notifications$"; } ];
      block-out-from = "screen-capture";
      opacity = 0.8;
    }
  ];
}
