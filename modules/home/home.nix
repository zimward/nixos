{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "zimward";
  home.homeDirectory = "/home/zimward";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;  
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/zimward/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "helix";
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "nu -c bemenu-run | xargs swaymsg exec --";
      startup = [
        {command = "dbus-sway-environment";}
        {command = "configure-gtk";}
      ];
      bars = [
        {
          position = "top";
        }
      ];
      input = {
        "type:keyboard" = {xkb_layout = "de,de"; xkb_variant = "dvorak,"; xkb_numlock="enabled";};
      };
      keybindings = lib.mkOptionDefault {
        "${modifier}+Shift+t" = "exec ${terminal}";
        "${modifier}+p" = "exec ${menu}";
        "${modifier}+BackSpace" = "input type:keyboard xkb_switch_layout next";
      };
    };
  };
  programs.nushell = {
    enable = true;
    configFile.source = ./nushell/config.nu;
    envFile.source = ./nushell/env.nu;
  };

  programs.starship={
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = false;
    enableFishIntegration = false;
    
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
