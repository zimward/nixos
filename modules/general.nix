{pkgs, libs, config, inputs, ...}:
{
  imports = [
    ./user/main-user.nix
    ./desktop/sway.nix
    ./security.nix
    ./devel.nix
  ];

  environment.systemPackages = with pkgs; [
    nushell
    starship
    htop
  ];
  
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
      ${config.main-user.userName} = import ./home/home.nix;
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
