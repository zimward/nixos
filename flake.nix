{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # nixos-hardware-fork.url = "github:zimward/nixos-hardware/pinephone-pro";
    nixos-hardware-fork.url = "git+ssh://arcugit:/~/git/nixos-hardware?ref=pinephone-pro";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
    };

    pid-fan-controller = {
      # url = "github:zimward/PID-fan-control";
      url = "git+file:///home/zimward/gits/pid-fan-controller";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-generators,
      nix-matlab,
      ...
    }@inputs:
    let
      overlays = (
        { ... }:
        {
          nixpkgs.overlays = [ nix-matlab.overlay ];
        }
      );
    in
    rec {
      nixosConfigurations = {
        kalman = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            overlays
            ./hosts/kalman/configuration.nix
            inputs.pid-fan-controller.nixosModules.default
          ];
        };

        orsted = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            overlays
            ./hosts/orsted/configuration.nix
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t410
          ];
        };

        doga = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./hosts/doga/configuration.nix ];
        };

        kirishika = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            nixpkgs = nixpkgs-unstable;
          };
          modules = [
            (
              { ... }:
              {
                nixpkgs.hostPlatform.system = "aarch64-linux";
              }
            )
            ./hosts/kirishika/configuration.nix
            ./hosts/kirishika/hardware-configuration.nix
          ];
        };

        shila = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            (
              { ... }:
              {
                nixpkgs.hostPlatform.system = "aarch64-linux";
              }
            )
            ./hosts/shila/configuration.nix
            ./hosts/shila/hardware-configuration.nix
          ];
        };
      };
      packages.aarch64-linux = {
        kirishika.sdcard = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          specialArgs = {
            inherit inputs;
            nixpkgs = nixpkgs-unstable;
          };
          modules = [
            (
              { ... }:
              {
                sdImage.compressImage = true;
                nixpkgs.config.allowUnsupportedSystem = true;
                nixpkgs.hostPlatform.system = "aarch64-linux";
                nixpkgs.buildPlatform.system = "aarch64-linux";
              }
            )
            ./hosts/kirishika/configuration.nix
          ];
        };
        shila.sdcard = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            (
              { ... }:
              {
                nixpkgs.config.allowUnsupportedSystem = true;
                nixpkgs.hostPlatform.system = "aarch64-linux";
                nixpkgs.buildPlatform.system = "aarch64-linux";

                sdImage.compressImage = false;
              }
            )
            ./hosts/shila/configuration.nix
          ];
        };
      };
      hydraJobs = {
        kirishika = packages.aarch64-linux.kirishika.sdcard;
      };
    };
}
