{config,pkgs,...}:
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "tokyonight";
      keys.insert = {
        "C-d" = "normal_mode";
      };
      keys.normal = {
        "C-5" = ":run-shell-command cargo run";
      };
    };
    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
    }];
  };
  

  programs.git = {
    enable = true;
    userName = "zimward";
    userEmail = "96021122+zimward@users.noreply.github.com";
    aliases = {
      "commit" = "commit -S";
    };
    extraConfig = {
      commit = { gpgsign = true; };
      safe = { directory = "/etc/nixos/"; };
      user = { signingkey = "CBF7FA5EF4B58B6859773E3E4CAC61D6A482FCD9"; };
    };
  };
}
