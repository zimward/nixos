{ lib, ... }:
{
  services.pipewire.extraConfig.pipewire =
    let
      mkParam = f: q: g: {
        "Freq" = f;
        "Q" = q;
        "Gain" = g;
      };
      bands = [
        {
          type = "bq_lowshelf";
          params = mkParam 105.0 0.7 3.0;
        }
        {
          type = "bq_peaking";
          params = mkParam 113.0 0.25 (-3.0);
        }
        {
          type = "bq_peaking";
          params = mkParam 786.0 1.49 (-5.5);
        }
        {
          type = "bq_peaking";
          params = mkParam 4375.0 3.44 5.1;
        }
        {
          type = "bq_peaking";
          params = mkParam 8088.0 1.7 (-3.9);
        }
        {
          type = "bq_peaking";
          params = mkParam 56.0 1.21 (-0.7);
        }
        {
          type = "bq_peaking";
          params = mkParam 130.0 1.42 0.6;
        }
        {
          type = "bq_peaking";
          params = mkParam 1538.0 3.73 2.0;
        }
        {
          type = "bq_peaking";
          params = mkParam 2556.0 3.68 (-2.4);
        }
        {
          type = "bq_highshelf";
          params = mkParam 10000.0 0.7 0.5;
        }
      ];
      idx = lib.genList (x: x) (builtins.length bands);
      #enumerated list
      enum = map (x: {
        i = x;
        v = builtins.elemAt bands x;
      }) idx;
      mkBand =
        x:
        let
          band = x.v;
          n = builtins.toString x.i;
        in
        {
          type = "builtin";
          name = "eq_band_${n}";
          label = band.type;
          control = band.params;
        };
      mkLink =
        x:
        let
          n = x.i;
        in
        {
          output = "eq_band_${builtins.toString (n - 1)}:Out";
          input = "eq_band_${builtins.toString n}:In";
        };
    in
    {
      "90-sink-siberia" = {
        "context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.description" = "Equalizer Sink";
              "media.name" = "Equalizer Sink";
              "filter.graph" = {
                nodes = map mkBand enum;
                #cant link first element to something
                links = map mkLink (builtins.tail enum);
              };
              "audio.channels" = 2;
              "audio.position" = [
                "FL"
                "FR"
              ];
              "capture.props" = {
                # "node.name" = "effect_input.eq6";
                "media.class" = "Audio/Sink";
                "audio.position" = [
                  "FL"
                  "FR"
                ];
              };
              "playback.props" = {
                # "node.name" = "effect_output.eq6";
                "node.passive" = true;
                "node.dont-remix" = true;
                "audio.position" = [
                  "FL"
                  "FR"
                ];
              };
            };
          }
        ];
      };
    };
}
