{
  pkgs,
  lib,
  fetchgit,
  ...
}: let
  kernelPatches = [
    # "0001-arm64-dts-rockchip-set-type-c-dr_mode-as-otg.patch"
    # "0001-dts-pinephone-pro-Setup-default-on-and-panic-LEDs.patch"
    "0001-usb-dwc3-Enable-userspace-role-switch-control.patch"
  ];
  applyPatches = p: {
    name = p;
    patch = ./${p};
  };
in {
  boot.kernelPatches = lib.lists.forEach kernelPatches applyPatches;
  boot.initrd.kernelModules = [
    # Rockchip modules
    "rockchip_rga"
    "rockchip_saradc"
    "rockchip_thermal"
    "rockchipdrm"

    # GPU/Display modules
    "analogix_dp"
    "cec"
    "drm"
    "drm_kms_helper"
    "dw_hdmi"
    "dw_mipi_dsi"
    "gpu_sched"
    "panel_edp"
    "panel_simple"
    "panfrost"
    "pwm_bl"

    # USB / Type-C related modules
    "fusb302"
    "tcpm"
    "typec"

    # PCIe/NVMe
    "nvme"
    "pcie_rockchip_host"
    "phy_rockchip_pcie"

    # Misc. modules
    "cw2015_battery"
    "gpio_charger"
    "rtc_rk808"
  ];

  networking.networkmanager.wifi.powersave = lib.mkDefault false;
}
