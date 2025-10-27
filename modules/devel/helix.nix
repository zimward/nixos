{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  hx = inputs.wrappers.wrapperModules.helix.apply {
    inherit pkgs;
    extraPackages =
      with pkgs;
      [
        nixd
      ]
      ++ lib.optionals config.graphical.enable [
        texlab # latex lsp
        lldb_18
        clang-tools
      ];

    themes = {
      tokyonight = {
        inherits = "tokyonight";
        "ui.background" = { };
        "ui.text" = { };
      };
    };

    ignores = [
      ".jj"
      ".git"
      "result"
    ];

    settings = {
      editor = {
        line-number = "relative";
        # completion-replace = true;
        true-color = true;
        rulers = [
          80
          120
        ];
        color-modes = true;
        #dvorak home row etc
        jump-label-alphabet = "aoeidrnsuhlqwt";
        # lsp = {
        #   display-inlay-hints = true;
        # };
        idle-timeout = 24000;
        indent-guides = {
          render = true;
          skip-levels = 1;
          character = "⸽";
        };
        #show warns end of line
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "error";
        };
      };
      theme = "tokyonight";
      keys.insert = {
        "up" = "no_op";
        "down" = "no_op";
        "right" = "no_op";
        "left" = "no_op";
        "C-d" = "normal_mode";
        "A-h" = "move_char_left";
        "A-d" = "move_visual_line_down";
        "A-r" = "move_visual_line_up";
        "A-n" = "move_char_right";
      };
      keys.select = {
        "C-d" = "normal_mode";
        "A-h" = "extend_char_left";
        "A-d" = "extend_visual_line_down";
        "A-r" = "extend_visual_line_up";
        "A-n" = "extend_char_right";
      };
      keys.normal = {
        "up" = "no_op";
        "down" = "no_op";
        "right" = "no_op";
        "left" = "no_op";
        "A-i" = [
          "add_newline_below"
          "move_line_down"
          "insert_mode"
        ];
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

    languages =
      let
        gattrs = x: lib.optionalAttrs config.graphical.enable x;
      in
      {
        #RA gets only installed via flake dev env so config is ok
        language-server.rust-analyzer = {
          config = {
            check = {
              command = "clippy";
              extraArgs = [
                "--"
                "-D"
                "clippy::pedantic"
                "-W"
                "clippy::nursery"
              ];
            };
          };
        };
        language-server.nixd = {
          command = lib.getExe pkgs.nixd;
        };
        #doesn't make sense to have on a server
        language-server.superhtml = gattrs {
          command = lib.getExe pkgs.superhtml;
          args = [ "lsp" ];
        };
        language-server.ltexpp = gattrs {
          command = "${pkgs.ltex-ls-plus}/bin/ltex-ls-plus";
        };
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter = {
              command = lib.getExe pkgs.nixfmt-rfc-style;
            };
            language-servers = [ "nixd" ];
          }
          {
            name = "rust";
            auto-format = true;
            formatter = {
              command = lib.getExe pkgs.rustfmt;
            };
          }
        ]
        ++ lib.optionals config.graphical.enable [
          {
            name = "html";
            auto-format = true;
            file-types = [
              "html"
              "css"
            ];
            language-servers = [ "superhtml" ];
          }
          {
            name = "latex";
            auto-format = true;
            language-servers = [
              "texlab"
              "ltexpp"
            ];
          }
        ];
      };
  };
in
{
  options = {
    devel.helix.enable = lib.mkEnableOption "Helix editor";
  };
  config = lib.mkIf config.devel.helix.enable {
    environment.systemPackages = [ hx ];
    environment.sessionVariables = {
      EDITOR = lib.getExe hx;
    };
  };
}
