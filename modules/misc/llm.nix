{
  config,
  lib,
  pkgs,
  ...
}:
let
  iniFmt = pkgs.formats.ini { };
  mkPreset = s: toString (iniFmt.generate "preset.ini" s);
  models-dir = "/nix/persist/system/var/lib/llama-cpp/models";
in
{
  options.misc.llm.enable = lib.mkEnableOption "LLM (via llama-swap)";
  config = lib.mkIf config.misc.llm.enable {
    services.llama-cpp = {
      enable = true;
      package = pkgs.llama-cpp-vulkan;
      settings = {
        inherit models-dir;

        models-preset = mkPreset {
          #fim trained model
          "qwen3.5-0.8b" = {
            model = "qwen3.5-0.8B-fim-finetune-q4_k_m.gguf";
            c = 512;
            n-gpu-layers = 99;
          };
          "qwen3-coder-next" = {
            model = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
            cpu-moe = 1;
          };
        };

      };
    };
    systemd.services.llama-cpp.serviceConfig = {
      WorkingDirectory = lib.mkForce models-dir;
      StateDirectory = lib.mkForce "";
      CacheDirectory = lib.mkForce "llama-cpp";
    };
  };
}
