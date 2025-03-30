{ ... }:
{
  programs.niri.settings.window-rules = [
    #prevent starting applications from grabbing focus
    {
      matches = [ { app-id = ".*"; } ];
      excludes = [ { app-id = "org.keepassxc.KeePassKC"; } ];
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
      ];
      open-on-workspace = "2";
      open-on-output = "DP-3";
    }
    {
      matches = [ { app-id = "steam"; } ];
      open-on-workspace = "3";
      open-on-output = "DP-3";
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
        { app-id = "freetube"; }
      ];
      default-column-width.proportion = (1.0 - 0.18);
      default-window-height.proportion = 1.0;
      open-on-output = "DP-1";
    }
  ];
}
