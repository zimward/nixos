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
    # Remove perl from activation
    boot.initrd.systemd.enable = lib.mkDefault true;
    system.etc.overlay.enable = lib.mkDefault true;
    services.userborn.enable = lib.mkDefault true;
    system.disableInstallerTools = true;
    system.tools.nixos-rebuild.enable = true;
    system.tools.nixos-version.enable = true;
    boot.enableContainers = lib.mkDefault false;

    environment.defaultPackages = lib.mkDefault [ ];

    #needed to rebuild system
    environment.systemPackages = lib.optionals config.devel.git.enable [ pkgs.gitMinimal ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];

    #doesn't hurt
    zramSwap.enable = true;

    time.timeZone = lib.mkDefault "Europe/Berlin";
    i18n.defaultLocale = "de_DE.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "dvorak-de";
    };

    mainUser.userName = "zimward";
    services.getty.autologinUser = config.mainUser.userName;
    services.getty.autologinOnce = true;

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
    services.logind.settings.Login.HandlePowerKey = "suspend";

    services.btrfs.autoScrub.enable = true;

    #enable sysrq
    boot.kernel.sysctl."kernel.sysrq" = 598;
    #DONT USE PROVIDER DNS
    networking.nameservers = [
      "1.1.1.1"
      "2606:4700:4700::1111"
    ];
    services.resolved = {
      enable = true;
      settings.Resolve.FallbackDNS = [
        "8.8.8.8"
        "2001:4860:4860::8888"
      ];
    };
    networking.useNetworkd = true;

    services.openssh.knownHosts = {
      "zimward.moe" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAI36kh/wRoNrwraNaKRtiM4b9j5HY3NwzNfE2OqGQT";
      };
    };
    #fails too often in certain configs
    services.logrotate.checkConfig = false;
    #prevent shutdown hanging for minutes
    systemd.settings.Manager = {
      DefaultTimeoutStopSec = "10s";
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
    nix.registry.n.to = config.nix.registry.nixpkgs.to;

    systemd.services.nixos-upgrade.environment = {
      GIT_SSH_COMMAND = lib.optionalString (
        config.update.accessKey != null
      ) "ssh -i ${config.update.accessKey}";
    };

    #oldest possible state
    system.stateVersion = lib.mkDefault "23.11";
  };
}
