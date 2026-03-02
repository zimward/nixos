{ pkgs, ... }:
let
  compressionConf = ''
    gzip "on";
    gzip_types  "text/plain" "text/html" "application/json" "application/xml" "application/wasm";
    gzip_min_length 256;
    zstd "on";
    zstd_comp_level 4;
    zstd_min_length 256;
    zstd_types  "text/plain" "text/html" "application/json" "application/xml" "application/wasm";
  '';

  sable = pkgs.callPackage (
    {
      lib,
      buildNpmPackage,
      fetchFromGitHub,
      giflib,
      python3,
      pkg-config,
      pixman,
      nodejs_24,
      cairo,
      pango,
      stdenv,
    }:

    buildNpmPackage (finalAttrs: {
      pname = "sable";
      version = "1.0.0-dev";

      src = fetchFromGitHub {
        owner = "7w1";
        repo = "sable";
        rev = "90dd4c721a71cd1365372481ef250b8b39c7ec39";
        hash = "sha256-4JTz7yIvINQWKv2VXU2WyO/s6Urihv1Fg/cO/GOH73U=";
      };

      nodejs = nodejs_24;

      npmDepsHash = "sha256-ElKLaNWFJJivo3cby9ALfCwWC+fNE3mF5jgpJ+/9KEc=";

      nativeBuildInputs = [
        python3
        pkg-config
      ];

      buildInputs = [
        pixman
        cairo
        pango
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ giflib ];

      installPhase = ''
        runHook preInstall

        cp -r dist $out

        runHook postInstall
      '';
    })
  ) { };

in
{
  services.nginx.virtualHosts."cinny.zimward.moe" = {
    forceSSL = true;
    enableACME = true;
    quic = true;
    locations."/" = {
      root = toString sable;
      extraConfig = ''
        etag on;
        rewrite ^/config.json$ /config.json break;
        rewrite ^/manifest.json$ /manifest.json break;
        rewrite ^/sw.js$ /sw.js break;
        rewrite ^/pdf.worker.min.js$ /pdf.worker.min.js break;
        rewrite ^/public/(.*)$ /public/$1 break;
        rewrite ^/assets/(.*)$ /assets/$1 break;
        rewrite ^(.+)$ /index.html break;
        ${compressionConf}
      '';
    };
  };
  services.nginx.virtualHosts."zimmy.zimward.moe" = {
    forceSSL = true;
    enableACME = true;
    quic = true;
    locations."/" = {
      return = "301 https://cinny.zimward.moe$request_uri";
    };
  };
}
