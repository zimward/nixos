{ inputs, pkgs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.default ];
  users.extraUsers."git" = {
    shell = "${pkgs.git}/bin/git-shell";
    createHome = true;
    homeMode = "700";
    ignoreShellProgramCheck = true;
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOL6wkiD+2gXU8TwEmBld1/2RdBJ4na2FnkYSYIjx4Ua zimward@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICInOBV9B6WDyTn0xb2VzkMznsaRiRF4kr3ytAAEhe7D deck@steamdeck"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuQ0J8g8iqBc6a6Q9xORmnjd1f7fV9R2u3jLKtoiZXE hydra@shila"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICHAAaJcIxgR7K1viqOD8CIAWNcNfU+RVX1hEti3HGq1 zimward@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbh53kKxAJtV5zyHiV+rz0MtJ7MZg5YDHwu2qoz9pkK zimward@shila"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkSxvX/P000vgk1Bb2exsC1eq8sY7UhPPo6pUm3OOgg modsog@mainpc"
    ];
  };
  home-manager.users."git".imports = [
    (
      { ... }:
      {
        home.username = "git";
        home.homeDirectory = "/home/git";

        home.stateVersion = "24.05";

        home.file."git-shell-commands/newrepo" = {
          text = ''
            !#${pkgs.bash}/bin/bash
            cd git
            mkdir $1
            cd $1
            ${pkgs.git}/bin/git init --bare
          '';
          executable = true;
        };
      }
    )
  ];
}
