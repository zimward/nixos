{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ../home ];
  options = {
    devel.helix.enable = lib.mkEnableOption "Helix editor";
  };
  config = lib.mkIf config.devel.helix.enable {
    #options provided by hm
    hm.modules = [
      (
        { ... }:
        {
          programs.helix = {
            enable = true;
            defaultEditor = true;
            extraPackages = with pkgs; [
              nixfmt-rfc-style
              nixd
              python311Packages.python-lsp-server
              texlab # latex
              lldb_18
            ];
            settings = {
              editor = {
                line-number = "relative";
                completion-replace = true;
                true-color = true;
                rulers = [
                  80
                  120
                ];
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
            languages = {
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
                command = "${pkgs.nixd}/bin/nixd";
              };
              language = [
                {
                  name = "nix";
                  auto-format = true;
                  formatter = {
                    command = "${pkgs.bash}/bin/bash";
                    args = [
                      "-c"
                      "${pkgs.gnused}/bin/sed s/[ \t]*$// || ${pkgs.nixfmt-rfc-style}/bin/nixfmt"
                    ];
                  };
                  language-servers = [ "nixd" ];
                }
              ];
            };
          };
        }
      )
    ];
  };
}
