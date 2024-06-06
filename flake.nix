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
      flake-overlays = [
        nix-matlab.overlay
        (final: prev: {
          unstable = import nixpkgs-unstable {
            system = prev.system;
          };
        })
      ];
    in
    {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/vm/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };

      nixosConfigurations.kalman = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          (import ./hosts/kalman/configuration.nix flake-overlays)
          inputs.home-manager.nixosModules.default
          inputs.impermanence.nixosModules.impermanence
          inputs.pid-fan-controller.default
        ];
      };

      nixosConfigurations.orsted = nixpkgs.lib.nixosSystem {
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

      nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/nas/configuration.nix
          inputs.home-manager.nixosModules.default
          inputs.impermanence.nixosModules.impermanence
        ];
      };
    };
}
