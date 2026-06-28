{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
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

    security.wrappers.pkexec.enable = false;

    environment.defaultPackages = lib.mkDefault [ ];

    #needed to rebuild system
    environment.systemPackages = lib.optionals config.devel.git.enable [ pkgs.gitMinimal ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operator"
    ];

    nix.package = pkgs.lixPackageSets.stable.lix;

    #doesn't hurt
    zramSwap.enable = true;
    boot.kernel.sysctl = {
      # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page_cluster" = 0;
    };

    time.timeZone = lib.mkDefault "Europe/Berlin";
    i18n.defaultLocale = "de_DE.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "dvorak-de";
    };

    mainUser.userName = "zimward";

    environment.persistence."/nix/persist/system" =
      lib.mkIf (config.tmpfsroot.enable || config.tmpfsroot.impermanence)
        {
          hideMounts = true;
          directories = [ "/var/lib/nixos" ];
          files = [
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
          ];
        };
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
      options = "--delete-older-than 3d";
    };
    nix.registry.n.to = config.nix.registry.nixpkgs.to;

    systemd.services.nixos-upgrade.environment = {
      GIT_SSH_COMMAND = lib.optionalString (
        config.update.accessKey != null
      ) "ssh -i ${config.update.accessKey}";
    };

    services.dbus.implementation = "broker";

    services.pid-fan-controller.package = pkgs.pid-fan-controller.overrideAttrs {
      version = "0.1.4";
      src = pkgs.fetchFromGitHub {
        owner = "zimward";
        repo = "pid-fan-controller";
        rev = "master";
        hash = "sha256-UtTyHftSaLO0x/5ROPbtdeoeeP9aTocvMxHF5DUdQSE=";
      };
      postInstall = ''
        install -Dm0644 resources/pid-fan-controller.service $out/lib/systemd/system/pid-fan-controller.service
      '';
    };

    #oldest possible state
    system.stateVersion = lib.mkDefault "23.11";
  };
}
