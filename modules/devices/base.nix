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
    ../misc/mainUser.nix
  ];
  options = {
    update = {
      cfgRef = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "git+ssh://git@zimward.moe/~/nixos";
        description = "reference to nix flake";
      };
      accessKey = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = "/etc/ssh/ssh_host_ed25519_key";
      };
    };
  };
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

    mainUser.userName = "zimward";
    services.getty.autologinUser = config.mainUser.userName;

    security.doas.enable = true;
    security.sudo.enable = false;
    security.doas.extraRules = [
      {
        users = [ config.mainUser.userName ];
        keepEnv = true;
        persist = true;
      }
    ];
    environment.persistence."/nix/persist/system" =
      lib.mkIf (config.tmpfsroot.enable || config.tmpfsroot.impermanence)
        {
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
    sops.age.keyFile = "/home/${config.mainUser.userName}/.config/sops/age/keys.txt";
    services.logind.powerKey = "suspend";

    #enable sysrq
    boot.kernel.sysctl."kernel.sysrq" = 598;
    #DONT USE PROVIDER DNS
    networking.nameservers = [
      "1.1.1.1"
      "2606:4700:4700::1111"
    ];
    services.resolved = {
      enable = true;
      dnssec = lib.mkDefault "true";
      dnsovertls = "true";
      llmnr = "false";
      domains = [ "~." ];
      fallbackDns = config.networking.nameservers;
    };
    networking.useNetworkd = true;

    services.openssh.knownHosts = {
      "zimward.moe" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAI36kh/wRoNrwraNaKRtiM4b9j5HY3NwzNfE2OqGQT";
      };
    };
    # auto system upgrade
    system.autoUpgrade = {
      enable = true;
      flake = config.update.cfgRef;
      persistent = true;
      dates = "10:00";
    };
    # nixos garbage collection automation
    nix.gc = {
      automatic = true;
      #gc profiles before update if /boot is full
      dates = "9:00";
      options = "--delete-older-than 5d";
    };
    systemd.services.nixos-upgrade.environment = {
      GIT_SSH_COMMAND = lib.optionalString (
        config.update.accessKey != null
      ) "ssh -i ${config.update.accessKey}";
    };
    #oldest possible state
    system.stateVersion = lib.mkDefault "23.11";
  };
}
