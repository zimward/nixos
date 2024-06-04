{pkgs, ...}: {
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      alejandra
      nil
      python311Packages.python-lsp-server
      texlab #latex
    ];
    settings = {
      theme = "tokyonight";
      keys.insert = {
        "C-d" = "normal_mode";
        "A-h" = "extend_char_left";
        "A-d" = "extend_visual_line_down";
        "A-r" = "extend_visual_line_up";
        "A-n" = "extend_char_right";
      };
      keys.normal = {
        "A-h" = "move_char_left";
        "A-d" = "move_line_down";
        "A-r" = "move_line_up";
        "A-n" = "move_char_right";
        "C-5" = ":run-shell-command cargo run";
      };
    };
    languages = {
      language-server.rust-analyzer = {
        config.check = {
          command = "clippy";
          extraArgs = ["--" "-W" "clippy::pedantic" "-W" "clippy::nursery"];
        };
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.alejandra}/bin/alejandra";
        }
      ];
    };
  };

  programs.git = {
    enable = true;
    userName = "zimward";
    userEmail = "96021122+zimward@users.noreply.github.com";
    aliases = {
      "commit" = "commit -S";
    };
    extraConfig = {
      commit = {gpgsign = true;};
      safe = {directory = "/etc/nixos/";};
      user = {signingkey = "CBF7FA5EF4B58B6859773E3E4CAC61D6A482FCD9";};
    };
  };
}
