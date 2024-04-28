{
  config,
  inputs,
  ...
}: {
  imports = [
    ./graphical
    ./devel/devel.nix
    ./wine.nix
    ./general_server.nix
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
}
