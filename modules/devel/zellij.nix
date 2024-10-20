{
  lib,
  config,
  pkgs,
  ...
}:
let
  zconf = ''
    keybinds clear-defaults=true {
      locked {
        bind "Ctrl g" {SwitchToMode "Normal";}
        bind "Ctrl h" {GoToPreviousTab;}      
        bind "Ctrl n" {GoToNextTab;}      
      }
      normal {
        bind "Ctrl g" {SwitchToMode "locked";}
        bind "Ctrl n" {NewTab;}
        bind "Ctrl x" {CloseTab;}
      }
    }
  '';
  layout = ''
    plugins clear-defaults=true {
      tab-bar location="zellij:tab-bar"
    }
    layout {
      tab focus=true{
        pane size=1 borderless=true{
          plugin location="tab-bar"
        }
        pane borderless=true command="nix"{
          args "develop" "--command" "hx"
        }
      }
      tab{
        pane size=1 borderless=true{
          plugin location="tab-bar"
        }
        pane borderless=true
      }
    }
  '';
in
{
  options = {
    devel.zellij.enable = lib.mkEnableOption "zelji terminal multiplexer";
  };
  config = lib.mkIf config.devel.zellij.enable {
    environment.systemPackages = [ pkgs.zellij ];
    hm.modules = [
      (
        { ... }:
        {
          home.file = {
            ".config/zellij/config.kdl".text = zconf;
            ".config/zellij/layouts/default.kdl".text = layout;
          };
        }
      )
    ];
  };
}
