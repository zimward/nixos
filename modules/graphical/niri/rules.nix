[
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
    ];
    default-column-width.proportion = 1.0;
  }
  {
    matches = [
      { app-id = "steam"; }
      { app-id = "org.prismlauncher.PrismLauncher"; }
    ];
    default-column-width.proportion = 1.0;
  }
  #mumble proportions
  {
    matches = [
      { app-id = "info.mumble.Mumble"; }
    ];
    default-column-width.proportion = 0.18;
    default-window-height.proportion = 0.5;
  }
  {
    matches = [
      { app-id = "FreeTube"; }
    ];
    default-column-width.proportion = (1.0 - 0.18);
    default-window-height.proportion = 1.0;
  }
  {
    matches = [ { app-id = "librewolf"; } ];
    open-maximized = true;
  }
  {
    matches = [ { app-id = "librewolf"; } ];
    excludes = [ { title = "^.*LibreWolf$"; } ];
    open-floating = true;
    open-focused = true;
  }
  {
    matches = [
      { app-id = "^MATLAB+.*$"; }
    ];
    open-floating = true;
  }
  {
    matches = [
      { title = "^Feld.*$"; }
      { title = "^.*eigenschaften$"; }
    ];
    open-floating = true;
    open-focused = true;
  }
  {
    matches = [
      { app-id = "gay.vaskel.soteria"; }
    ];
    open-floating = true;
    open-focused = true;
    block-out-from = "screen-capture";
  }
]
