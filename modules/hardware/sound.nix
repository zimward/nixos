{ lib, config, ... }:
{
  options = {
    sys.sound = {
      enable = lib.mkEnableOption "Sound";
      allowRTsched = lib.mkOption {
        default = config.device.class == "desktop" || config.device.class == "mobile";
        type = lib.types.bool;
        description = "Whether to enable realtime scheduling via rtkit";
      };
    };
  };
  config = lib.mkIf config.sys.sound.enable {
    hardware.pulseaudio.enable = false;
    #allow user processes to run with realitme scheduling
    security.rtkit.enable = config.sys.sound.allowRTsched;
    services.pipewire = {
      enable = true;
      #may need to enable alsa if some applications need it
      alsa.enable = false;
      alsa.support32Bit = false;
      pulse.enable = true;
    };
  };
}
