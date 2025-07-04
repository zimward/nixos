{ pkgs, ... }:
let
  version = "4.1.2";
  filen = freq: "SteelSeries Siberia 200 minimum phase ${builtins.toString freq}Hz.wav";
  convFile = pkgs.stdenvNoCC.mkDerivation {
    name = "autoeq";
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "jaakkopasanen";
      repo = "AutoEq";
      rev = version;
      hash = "sha256-bNqgxDQUIj4hDCIZzASFtEu3L64EYBCcBJYuWApBZ4c=";
    };
    buildPhase = ''
      mkdir -p $out/
      cp $src/results/Rtings/over-ear/SteelSeries\ Siberia\ 200/*.wav $out/
    '';
  };
in
{
  services.pipewire.extraConfig.pipewire = {
    "99-sink-siberia" = {
      "node.description" = "Steelseries Siberia";
      "media.name" = "Steelseries Siberia";
      "filter.graph" = {
        nodes = [
          {
            type = "builtin";
            label = "convolver";
            name = "conv";
            config = {
              filename = map (f: "${convFile}/${filen f}") [
                44100
                48000
              ];
              gain = 1;
            };
          }
        ];
        links =
          let
            lk = input: output: { inherit input output; };
          in
          [
            (lk "SteelSeries Siberia 840:in_l" "conv")
            (lk "conv" "siberia_dsp:out_l")
          ];
        inputs = [
          "SteelSeries Siberia 840:in_l"
        ];
        outputs = [ "siberia_dsp:out_l" ];
      };
      "capture.props" = {
        "node.name" = "audio_effect.convolver";
        "media.class" = "Audio/Sink";
        "audio.channels" = "2";
        "audio.position" = [
          "FL"
          "FR"
        ];
        "device.api" = "dsp";
        "audio.allowed-rates" = [
          48000
          44100
        ];
        "node.virtual" = "false";
        "priority.session" = 850;
        # "state.default-volume"= 0.343;
        "device.icon-name" = "audio-speakers";
      };
      "playback.props" = {
        "node.name" = "effect_output.convolver";
        "node.passive" = "false";
      };
    };
  };
}
