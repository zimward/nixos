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
          llama-cpp = pkgs.llama-cpp-rocm;
          llama-server = lib.getExe' llama-cpp "llama-server";

          buildModel =
            {
              name,
              filename,
              isMoe ? false,
              extraArgs ? "",
            }:
            {
              ${name} = {
                cmd =
                  "${llama-server} --port \${PORT} -m /var/lib/llama-cpp/models/${filename} -ngl 99 -fit on ${extraArgs}"
                  + lib.optionalString isMoe " --cpu-moe";
              };
            };

          modelList = [
            {
              name = "qwen3.5-2b";
              filename = "Qwen3.5-2B-f16_q8_0.gguf";
              extraArgs = "--chat-template-kwargs \'{\"enable_thinking\": false}\'";
            }
            {
              name = "qwen2.5-3b";
              filename = "Qwen2.5-Coder-3B-Q8_0.gguf";
              extraArgs = "-md /var/lib/llama-cpp/models/Qwen2.5-Coder-0.5B-Q8_0.gguf";
            }
            {
              name = "qwen3-coder-next";
              filename = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
              isMoe = true;
            }
            {
              name = "qwen3.5-4b-zeta";
              filename = "Qwen3-4B-Q8-finetune.gguf";
              extraArgs = "--chat-template-kwargs \'{\"enable_thinking\": false}\'";
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
