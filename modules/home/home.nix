{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "zimward";
  home.homeDirectory = "/home/zimward";
  imports = [
    ../graphical/sway_cfg.nix
  ];
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

  programs.helix = {
    enable = true;
    settings = {
      theme = "tokyonight";
      keys={
        insert = {
          "C-d" = '''"normal mode"'';
        };
        normal = {
          "C-5" = ''":run-shell-command cargo run"'';
        };
      };
    };
    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
    }];
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
    settings = {
      format = 
        "[░▒▓](#a3aed2)"+
        "[   ](bg:#a3aed2 fg:#090c0c)"+
        "[](bg:#769ff0 fg:#a3aed2)"+
        "\$directory"+
        "[](fg:#769ff0 bg:#394260)"+
        "\$git_branch"+
        "\$git_status"+
        "[](fg:#394260 bg:#212736)"+
        "\$rust"+
        "[](fg:#212736 bg:#1d2230)"+
        "\$time"+
        "[ ](fg:1d2230)"+
        "\n$character";
      directory = {
        style = "fg:#e3e5e5 bg:#769ff0";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      rust = {
        symbol = "";
        style = "bg:#212736";
        format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
      };
      git_status = {
        style = "bg:#394260";
        format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
      };
      git_branch = {
        symbol = "";
        style = "bg:#394260";
        format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
      };
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#1d2230";
        format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
        
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
