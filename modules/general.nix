{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./graphical
    ./devel/devel.nix
    ./wine.nix
    ./general_server.nix
    ./unfree.nix
  ];

  config.nixpkgs.allowUnfreePackages = [
    "obsidian"
    "steam"
    "steam-original"
    "steam-run"
  ];
  config = {
    environment.sessionVariables = {
      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
    };

    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
      };
      users = {
        ${config.main-user.userName} = import ./home/default.nix;
      };
    };
    #sound
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    #allow user processes to run with realitme scheduling
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      #may need to enable alsa if some applications need it
      alsa.enable = false;
      alsa.support32Bit = false;
      pulse.enable = true;
    };

    # opengl 32bit support
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
  };
}
