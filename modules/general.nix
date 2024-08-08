{ ... }:
{
  imports = [
    ./graphical
    ./devel
    ./misc/wine.nix
    ./general_server.nix
    ./hardware/automounting.nix
    ./hardware/sound.nix
    ./home
  ];

  config = {
    latex = true;
    devel = {
      helix.enable = true;
      git.enable = true;
      zellij.enable = true;
    };
    environment.sessionVariables = {
      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
      PATH = "$HOME/.local/bin/";
    };
    net.filter.enable = true;
    #running ssh agent on graphical hosts is most often needed
    cli.ssh.enableAgent = true;
    #sound
    sys.sound.enable = true;
  };
}
