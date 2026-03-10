{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.misc.ollama.enable = lib.mkEnableOption "ollama";
  config = {
    services.nextjs-ollama-llm-ui = {
      enable = config.misc.ollama.enable;
    };
    services.ollama = {
      enable = config.misc.ollama.enable;
      package = pkgs.ollama-vulkan;
    };
  };
}
