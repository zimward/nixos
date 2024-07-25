{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
      url = "github:zimward/PID-fan-control";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ppp-kernel = {
      url = "git+ssh://arcugit:/~/git/ppp-kernel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #soppps-nix = {
    #  url = "git+file:/home/zimward/gits/soppps-nix";
    #};
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-generators,
      nix-matlab,
      ppp-kernel,
      ...
    }@inputs:
    let
      unst_overlay = final: prev: { unstable = import nixpkgs-unstable { system = final.system; }; };
      flake-overlays = [
        nix-matlab.overlay
        unst_overlay
      ];
      overlays = (
        { ... }:
        {
          nixpkgs.overlays = flake-overlays;
        }
      );
    in
    {
      nixosConfigurations = {
        # testing vm
        vm = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            overlays
            ./hosts/vm/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        kalman = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            unstable = nixpkgs-unstable;
          };
          modules = [
            overlays
            ./hosts/kalman/configuration.nix
            inputs.home-manager.nixosModules.default
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
            inputs.home-manager.nixosModules.default
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t410
          ];
        };

        doga = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/doga/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

        kirishika = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            (
              { ... }:
              {
                # imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];
                nixpkgs.overlays = [ unst_overlay ];
                nixpkgs.hostPlatform.system = "aarch64-linux";
              }
            )
            ./hosts/kirishika/configuration.nix
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
                nixpkgs.overlays = [ unst_overlay ];
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
          };
          modules = [
            (
              { ... }:
              {
                nixpkgs.overlays = [ unst_overlay ];
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
                nixpkgs.overlays = [ unst_overlay ];
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
        inherit (self) packages;
      };
    };
}
