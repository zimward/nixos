{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    wrappers = {
      url = "github:lassulus/wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    run0-sudo-shim = {
      url = "github:lordgrimmauld/run0-sudo-shim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@zimward.moe/~/secrets";
    };

  };

  outputs =
    {
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
              modules = [
                (./hosts + "/${name}/config.nix")
                ./modules
              ];
            };
          };
          getDirs =
            path:
            builtins.readDir path |> nixpkgs.lib.filterAttrs (n: v: v == "directory") |> builtins.attrNames;
          dirs = getDirs ./hosts;
          isSmall =
            dir: builtins.readFile (./hosts + "/${dir}/config.nix") |> nixpkgs.lib.strings.hasPrefix "#!small";
          small = (builtins.filter isSmall dirs);
          big = builtins.filter (d: !(isSmall d)) dirs;
        in
        builtins.listToAttrs ((map (mkSys nixpkgs) big) ++ (map (mkSys nixpkgs-small) small));
    };
}
