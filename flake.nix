{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # nixos-hardware-fork.url = "github:zimward/nixos-hardware/pinephone-pro";
    # nixos-hardware-fork.url = "git+ssh://shilagit:/~/git/nixos-hardware?ref=pinephone-pro";

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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ppp-kernel.url = "git+ssh://shilagit:/~/git/ppp-kernel";

    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-small,
      # nixos-generators,
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
    {
      nixosConfigurations = {
        kalman = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            overlays
            ./hosts/kalman/configuration.nix
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

        doga = nixpkgs-small.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/doga/configuration.nix
            (
              { ... }:
              {
                environment.systemPackages = [ self.nixosConfigurations.kalman.config.system.build.toplevel ];
              }
            )
          ];
        };
        aisha = nixpkgs-small.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./hosts/aisha/configuration.nix ];
        };

        # kirishika = nixpkgs.lib.nixosSystem {
        #   specialArgs = {
        #     inherit inputs;
        #   };
        #   modules = [
        #     (
        #       { ... }:
        #       {
        #         nixpkgs.hostPlatform.system = "aarch64-linux";
        #       }
        #     )
        #     ./hosts/kirishika/configuration.nix
        #     ./hosts/kirishika/hardware-configuration.nix
        #   ];
        # };

        shila = nixpkgs-small.lib.nixosSystem {
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
      # packages.aarch64-linux = {
      #   kirishika.sdcard = nixos-generators.nixosGenerate {
      #     system = "aarch64-linux";
      #     format = "sd-aarch64";
      #     specialArgs = {
      #       inherit inputs;
      #     };
      #     modules = [
      #       (
      #         { ... }:
      #         {
      #           sdImage.compressImage = true;
      #           nixpkgs.config.allowUnsupportedSystem = true;
      #           nixpkgs.hostPlatform.system = "aarch64-linux";
      #           nixpkgs.buildPlatform.system = "aarch64-linux";
      #         }
      #       )
      #       ./hosts/kirishika/configuration.nix
      #     ];
      #   };
      # };
      # hydraJobs = {
      #   kirishika = packages.aarch64-linux.kirishika.sdcard;
      # };
    };
}
