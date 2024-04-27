
{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./main-user.nix
    ./security.nix
    ./undesired.nix
    ./cli.nix
  ];

  environment.systemPackages=with pkgs;[
    git
  ];

  environment.sessionVariables = {
    EDITOR = "${pkgs.helix}/bin/hx";
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak-de";
  };

  main-user.userName = "zimward";
  services.getty.autologinUser = config.main-user.userName;
  
  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [
    {
      users = [config.main-user.userName];
      keepEnv = true;
      persist = true;
    }
  ];

  environment.persistence."/nix/persist/system" = {
    hideMounts = true;
    directories = [
    "/var/lib/nixos"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
  
  # auto system upgrade
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = ["--update-input" "nixpkgs"];
    dates = "10:00";
  };
  # nixos garbage collection automation
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };
}
