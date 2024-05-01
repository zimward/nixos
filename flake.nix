{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #soppps-nix = {
    #  url = "git+file:/home/zimward/gits/soppps-nix";
    #};
  };

  outputs = {
    self,
    nixpkgs,
    nix-matlab,
    ...
  } @ inputs: let
    flake-overlays = [
      nix-matlab.overlay
    ];
  in {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/vm/configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };

    nixosConfigurations.kalman = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        (import ./hosts/workstation/configuration.nix)
        inputs.home-manager.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
      ];
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        (import ./hosts/laptop/configuration.nix flake-overlays)
        inputs.home-manager.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
      ];
    };

    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/nas/configuration.nix
        inputs.home-manager.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
      ];
    };
  };
}
