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
