{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./graphical
    ./devel/devel.nix
    ./wine.nix
    inputs.sops-nix.nixosModules.sops
    inputs.soppps-nix.nixosModules.soppps
  ];

  environment.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    MOZ_ENABLE_WAYLAND = "1";
    SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
  };

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
  # soppps.files = ["/run/NetworkManager/system-connections/*.nmconnection"];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
