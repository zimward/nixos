{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.default ];
  users.extraUsers."git" = {
    shell = "${pkgs.git}/bin/git-shell";
    createHome = true;
    home = "/nix/persist/git";
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGtFwpCXl8dkPEZTBloKTkJbSWmIzjFJE/29sDEwQVI/ zimward@doga"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAI36kh/wRoNrwraNaKRtiM4b9j5HY3NwzNfE2OqGQT root@nixos" # aisha
    ];
  };
  home-manager.users."git".imports = [
    (
      { ... }:
      {
        home.username = "git";
        # home.homeDirectory = lib.mkForce "/nix/persist/git";

        home.stateVersion = "24.05";

        home.file."git-shell-commands/newrepo" = {
          text = ''
            #!${lib.getExe pkgs.bash}
            mkdir $1
            cd $1
            ${lib.getExe pkgs.git} init --bare
          '';
          executable = true;
        };
      }
    )
  ];
}
