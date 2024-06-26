{
  config,
  lib,
  inputs,
  syscfg,
  ...
}: {
  imports = [
    ../graphical/sway_cfg.nix
    ./ssh.nix
    ./shell.nix
    ./devel.nix
    ./matlab.nix
    # inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  config = {
    home.username = syscfg.main-user.userName;
    home.homeDirectory = "/home/${syscfg.main-user.userName}";
    matlab.enable = true;
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
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
    };

    # home.persistence."/nix/persist/home/zimward/" = {
    #   directories = [
    #     ".local/share/keyrings"
    #     ".config/FreeTube"
    #     ".local/share/Mumble"
    #     ".config/Mumble"
    #     "Downloads"
    #     "Dokumente"
    #     ".local/share/Steam"
    #     ".factorio"
    #     "gits"
    #     "Anime"
    #     ".thunderbird"
    #     {
    #       directory = ".ssh";
    #       method = "symlink";
    #     }
    #   ];
    #   allowOther = true;
    # };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
