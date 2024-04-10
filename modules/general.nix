{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./main-user.nix
    ./graphical/sway.nix
    ./graphical/fonts.nix
    ./graphical/applications.nix
    ./security.nix
    ./undesired.nix
    ./devel/devel.nix
    ./cli.nix
    ./wine.nix
    inputs.sops-nix.nixosModules.sops
    inputs.soppps-nix.nixosModules.soppps
  ];

  environment.sessionVariables = {
    EDITOR = "${pkgs.helix}/bin/hx";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    MOZ_ENABLE_WAYLAND = "1";
    SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
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
    extraSpecialArgs = {inherit inputs;};
    users = {
      ${config.main-user.userName} = import ./home/default.nix;
    };
  };

  #systemd.sysusers.enable = true;
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${config.main-user.userName}/.config/sops/age/keys.txt";
  soppps.files = ["/run/NetworkManager/system-connections/*.nmconnection"];

  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [
    {
      users = [config.main-user.userName];
      keepEnv = true;
      persist = true;
    }
  ];
  # auto system upgrade
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = ["--update-input" "nixpkgs"];
    dates = "10:00";
  };
  # nixos garbage collection automation
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
