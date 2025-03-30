{ ... }:
{
  programs.niri.settings.window-rules = [
    #prevent starting applications from grabbing focus
    {
      matches = [ { app-id = ".*"; } ];
      excludes = [ { app-id = "org.keepassxc.KeePassXC"; } ];
      open-focused = false;
    }
    #disallow screencapture for keepass,etc.
    {
      matches = [
        { app-id = "org.keepassxc.KeePassXC"; }
        { app-id = "thunderbind"; }
        { app-id = "nheko"; }
      ];
      block-out-from = "screen-capture";
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
      open-floating = false;
    }
    {
      matches = [
        { app-id = "FreeTube"; }
      ];
      default-column-width.proportion = (1.0 - 0.18);
      default-window-height.proportion = 1.0;
      open-on-output = "DP-1";
    }
    {
      matches = [ { app-id = "librewolf"; } ];
      open-maximized = true;
      open-on-output = "DP-3";
      open-on-workspace = "1";
    }
  ];
}
