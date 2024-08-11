{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    ../../modules/general_server.nix
    inputs.nixos-hardware-fork.nixosModules.pine64-pinephone-pro
  ];
  config = {
    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    boot.initrd.kernelModules = [
      "gpu_sched"
      "dw_wdt"
      "fusb302"
      "panel_himax_hx8394"
      "goodix_ts"
    ];

    # boot.initrd.kernelModules = [
    #   # Rockchip modules
    #   "rockchip_rga"
    #   "rockchip_saradc"
    #   "rockchip_thermal"
    #   "rockchipdrm"

    #   # GPU/Display modules
    #   "cec"
    #   "drm"
    #   "drm_kms_helper"
    #   "dw_hdmi"
    #   "dw_mipi_dsi"
    #   "gpu_sched"
    #   "panel_edp"
    #   "panel_simple"
    #   "panfrost"
    #   "pwm_bl"

    #   # USB / Type-C related modules
    #   "fusb302"
    #   "tcpm"
    #   "typec"

    #   # PCIe/NVMe
    #   "pcie_rockchip_host"
    #   "phy_rockchip_pcie"

    #   # Misc. modules
    #   "cw2015_battery"
    #   "gpio_charger"
    #   "rtc_rk808"
    # ];

    boot.kernelPatches = [
      {
        name = "DMC patch";
        patch = ./0001-arm64-dts-rockchip-rk3399-pinephone-pro-Enable-DMC.patch;
      }
    ];
    boot.supportedFilesystems = lib.mkForce { zfs = false; };
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.powersave = true;

    nix.gc.automatic = lib.mkForce false; # causes image to eat itself when no rebuild switch is invoked

    hardware.enableRedistributableFirmware = true;
    security.apparmor.enable = lib.mkForce false;
    hardware.sensor.iio.enable = true;
    services.eg25-manager.enable = true;

    # hardware.pulseaudio.enable = false; # this is the default but for some reason this has to be set
    #allow user processes to run with realitme scheduling
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = true;
    # services.pipewire = {
    #   enable = true;
    #   alsa.enable = true;
    #   alsa.support32Bit = false;
    #   pulse.enable = true;
    # };
    services.openssh.enable = true;

    networking.firewall.enable = false;
    security.polkit.enable = true;

    users.users."${config.main-user.userName}".extraGroups = [
      "dialout"
      "feedbackd"
      "networkmanager"
      "video"
      "wheel"
      "audio"
      "bluetooth"
      "render"
    ];

    #graphical config
    services.xserver = {
      desktopManager.phosh = {
        enable = true;
        user = config.main-user.userName;
        group = "users";

      };
    };
    main-user.hashedPassword = "$y$j9T$tLtgJK7n2chx0mGQNUT/d/$2SJiFUqYsiYxbKaISRNCCKZ9Q7scfx.//MmqeVqxIHB";

    fonts.enableDefaultPackages = true; # enable default fonts
    programs.calls.enable = true;

    environment.systemPackages = [
      pkgs.cryptsetup
      pkgs.chatty
      pkgs.squeekboard
      pkgs.gnome-console
      pkgs.powersupply
      pkgs.bookworm
    ];

    system.stateVersion = "24.05";
  };
}
