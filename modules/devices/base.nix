{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence
  ];
  config = lib.mkIf (config.device.class != "none") {
    #needed to rebuild system
    environment.systemPackages = with pkgs; [
      git
      doas-sudo-shim
    ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    #doesn't hurt
    zramSwap.enable = true;

    environment.sessionVariables = {
      EDITOR = "${pkgs.helix}/bin/hx";
    };

    time.timeZone = lib.mkDefault "Europe/Berlin";
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
        users = [ config.main-user.userName ];
        keepEnv = true;
        persist = true;
      }
    ];
    environment.persistence."/nix/persist/system" = lib.mkIf config.tmpfsroot.enable {
      hideMounts = true;
      directories = [ "/var/lib/nixos" ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
    # soppps.files = ["/run/NetworkManager/system-connections/*.nmconnection"];
    sops.defaultSopsFile = ../../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";
    sops.age.keyFile = "/home/${config.main-user.userName}/.config/sops/age/keys.txt";
    services.logind.powerKey = "suspend";

    #enable sysrq
    boot.kernel.sysctl."kernel.sysrq" = 598;
    #DONT USE PROVIDER DNS
    networking.nameservers = [
      "1.1.1.1"
      "2606:4700:4700:1111"
    ];

    # auto system upgrade
    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
      ];
      persistent = true;
      dates = "10:00";
    };
    # nixos garbage collection automation
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 5d";
    };
  };
}
