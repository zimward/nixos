{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.misc.llm.enable = lib.mkEnableOption "LLM (via llama-swap)";

  config = lib.mkIf config.misc.llm.enable {
    services.llama-swap = {
      enable = true;
      settings =
        let
          llama-cpp = pkgs.llama-cpp-vulkan;
          llama-server = lib.getExe' llama-cpp "llama-server";

          # Helper: build model config from (name, { filename, isMoe ? false })
          buildModel =
            {
              name,
              filename,
              isMoe ? false,
            }:
            {
              ${name} = {
                cmd =
                  "${llama-server} --port \${PORT} -m /var/lib/llama-cpp/models/${filename} -ngl 99"
                  + lib.optionalString isMoe " --cpu-moe";
              };
            };

          # Your models: just list the data
          modelList = [
            {
              name = "qwen3.5-2b";
              filename = "Qwen3.5-2B-f16_q8_0.gguf";
            }
            {
              name = "qwen2.5-3b";
              filename = "Qwen2.5-Coder-3B-Q8_0.gguf";
            }
            {
              name = "qwen3-coder-next";
              filename = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
              isMoe = true;
            }
          ];

        in
        {
          # Merge all model configs into one attrset
          models = lib.foldl (acc: m: acc // buildModel m) { } modelList;
        };
    };
  };
}
