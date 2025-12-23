{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  configuredGit = inputs.wrappers.wrapperModules.git.apply {
    inherit pkgs;
    package = lib.mkForce pkgs.gitMinimal;
    settings.user = {
      name = "aisha";
      email = "auto-git@zimward.moe";
    };
  };
in
{
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVZ6ubHsaqWj2eyjEjS08zEHoFDmFhnV1xWaF0K+L9M root@kalman" # kalman
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZeN06ZB6hsWpWutEQQlGf0t/MBWSpu9jSYnVlOfKqj root@nas" # doga
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiyoos/yBEK/jdJdF+2gzjfX6FQD8+kyg/Q/eLMr4HK root@juliette"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHD1nysJ0LC+tg4r02bCaIRJ+3ZsJEh+91X7irPhtbn0 root@orsted"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAM5K72aFwFusw1z8dkJztHbaiWBl7T6s4fTp1Rkw3MC root@arumenfi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILG1gWO9yWvsjgO/L7mWnZGgLsSvlhElW3dafBJW8QRE zimward@arumanfi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnnZsVj7xIf4tqoK7foCj3dT8OMnyjgKZTsW6Q/Fvvm zimward@juliette"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSveEMHezj5v/JPfl9ES+00Z+lT4y4+m80ItAdXXSIV" # friendi
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICN157bDKVBfVzkdDb0xxHtvKN/leIwXKiWmBvcAEqTf" # git - self ssh for updates
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPdS0w5zf2JcGuSv4Q6MqvjnREh6FrwtGB0wMEehIwx6AAAABHNzaDo=" # nhnn
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmnknd6bSmWrhpr+I5j3R5fou8gu8zY4V3oc+gTfVuH" # kirottu
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnhIy51JVnJ5GlkWNqb0yAFPAfnipGXo+CUnc822BKR" # calops
    ];
  };
  systemd.timers.updateFlake = {
    enable = true;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "3:30";
      Unit = "updateFlake.service";
    };
  };
  environment.systemPackages = [ configuredGit.wrapper ];
  systemd.services.updateFlake = {
    enable = true;
    serviceConfig = {
      Type = "simple";
      User = "git";
      ExecStart = lib.getExe (
        pkgs.writeShellApplication {
          name = "updateFlake";
          runtimeInputs = [
            configuredGit.wrapper
            config.services.openssh.package
            config.nix.package
          ];
          text = ''
            cd "$(mktemp -d)"
            git clone git@zimward.moe:nixos
            cd nixos
            nix flake update
            git add flake.lock
            git commit -m "flake: update lock" && {
              git push
              cd ..
              rm -rf nixos
            }
          '';
        }
      );
    };
  };
}
