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
          "qwen3.6" = {
            model = "Qwen3.6-35B-A3B-UD-Q4_K_M.gguf";
            cpu-moe = 1;
            c = 100000;
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
