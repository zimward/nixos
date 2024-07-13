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
      url = "git+file:/home/zimward/gits/pid-fan-controller-nix";
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
      nix-matlab,
      ...
    }@inputs:
    let
      unst_overlay = final: prev: {
        unstable = import nixpkgs-unstable {
          system = final.system;
        };
      };
      flake-overlays = [
        nix-matlab.overlay
        unst_overlay
      ];
    in
    {
      nixosConfigurations = {
        # testing vm
        vm = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            (
              {
                config,
                pkgs,
                ...
              }:
              {
                nixpkgs.overlays = flake-overlays;
              }
            )
            ./hosts/vm/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.impermanence.nixosModules.impermanence
          ];
        };

        kalman = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            (
              {
                config,
                pkgs,
                ...
              }:
              {
                nixpkgs.overlays = flake-overlays;
              }
            )
            ./hosts/kalman/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.impermanence.nixosModules.impermanence
            inputs.pid-fan-controller.nixosModules.default
          ];
        };

        orsted = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            (import ./hosts/orsted/configuration.nix flake-overlays)
            inputs.home-manager.nixosModules.default
            inputs.impermanence.nixosModules.impermanence
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
            inputs.impermanence.nixosModules.impermanence
          ];
        };

        kirishika = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            (
              { config, ... }:
              {
                nixpkgs.overlays = [ unst_overlay ];
              }
            )
            ./hosts/kirishika/configuration.nix
          ];
        };
      };
    };
}
