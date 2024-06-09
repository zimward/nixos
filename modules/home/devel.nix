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
      editor = {
        line-number = "relative";
        completion-replace = true;
        true-color = true;
        rulers = [120];
        color-modes = true;
        #dvorak home row etc
        jump-label-alphabet = "aoeidrnsuhlqwt";
        lsp = {
          display-inlay-hints = true;
        };
        indent-guides = {
          render = true;
          skip-levels = 1;
          character = "⸽";
        };
      };
      theme = "tokyonight";
      keys.insert = {
        "C-d" = "normal_mode";
        "A-h" = "extend_char_left";
        "A-d" = "extend_visual_line_down";
        "A-r" = "extend_visual_line_up";
        "A-n" = "extend_char_right";
      };
      keys.normal = {
        "A-i" = ["add_newline_below" "move_line_down" "insert_mode"];
        "j" = {
          "p" = "goto_next_paragraph";
          "P" = "goto_prev_paragraph";
        };
        "A-h" = "move_char_left";
        "A-d" = "move_line_down";
        "A-r" = "move_line_up";
        "A-n" = "move_char_right";
        "C-5" = ":run-shell-command cargo run";
      };
    };
    languages = {
      language-server.rust-analyzer = {
        config = {
          check = {
            command = "clippy";
            extraArgs = ["--" "-D" "clippy::pedantic" "-W" "clippy::nursery"];
          };
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

  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "${pkgs.nushell}/bin/nu";
      keybinds = {
        pane = {
          "bind \"h\"" = {MoveFocus = "Left";};
          "bind \"n\"" = {MoveFocus = "Right";};
          "bind \"d\"" = {MoveFocus = "Down";};
          "bind \"r\"" = {MoveFocus = "Up";};
        };
      };
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
      push.autoSetupRemote = true;
      commit = {gpgsign = true;};
      safe = {directory = "/etc/nixos/";};
      user = {signingkey = "CBF7FA5EF4B58B6859773E3E4CAC61D6A482FCD9";};
    };
  };
}
