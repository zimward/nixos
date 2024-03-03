{pkgs, libs, config, inputs, ...}:
{
  imports = [
    ./main-user.nix
    ./graphical/sway.nix
    ./graphical/fonts.nix
    ./graphical/applications.nix
    ./security.nix
    ./undesired.nix
    ./devel/devel.nix
    ./cli.nix
  ];

  environment.sessionVariables = {
    EDITOR="${pkgs.helix}/bin/hx";
    SDL_VIDEODRIVER="wayland";
    QT_QPA_PLATFORM="wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION="1";
    _JAVA_AWT_WM_NONREPARENTING="1";
    MOZ_ENABLE_WAYLAND="1";
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
     font = "Lat2-Terminus16";
     keyMap = "dvorak-de";
  };

  
  main-user.userName = "zimward";
  services.getty.autologinUser = config.main-user.userName;
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      ${config.main-user.userName} = import ./home/default.nix;
    };
  };
  
  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [{
    users = [config.main-user.userName];
    keepEnv = true;
    persist = true;
  }];
}
