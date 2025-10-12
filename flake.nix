{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@zimward.moe/~/secrets";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-small,
      ...
    }@inputs:
    {
      nixosConfigurations =
        let
          mkSys = nixp: name: {
            inherit name;
            value = nixp.lib.nixosSystem {
              specialArgs = { inherit inputs; };
              modules = [ (./hosts + "/${name}/configuration.nix") ];
            };
          };
        in
        {
          kalman = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
              ./hosts/kalman/configuration.nix
              inputs.lanzaboote.nixosModules.lanzaboote
            ];
          };
          arumanfi = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
              ./hosts/arumanfi/configuration.nix
            ];
          };

          orsted = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
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
              {
                environment.systemPackages = [ self.nixosConfigurations.kalman.config.system.build.toplevel ];
              }
            ];
          };
          aisha = nixpkgs-small.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [ ./hosts/aisha/configuration.nix ];
          };

          juliette = nixpkgs-small.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [ ./hosts/juliette ];
          };

        }
        // builtins.listToAttrs (
          map (mkSys nixpkgs) [
            "arumanfi"
          ]
        );
    };
}
