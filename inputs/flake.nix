{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
      flake = false;
    };

    secrets = {
      url = "git+ssh://git@zimward.moe/~/secrets";
      flake = false;
    };

    wrappers = {
      url = "github:lassulus/wrappers";
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
      url = "github:zimward/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/001e560fffc8f0235e9db20ebeb4ccde0ade1caf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codel = {
      url = "github:zimward/codel/push-yqnmoxktuvrq";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cache-beacon = {
      url = "github:adisbladis/nix-cache-beacon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = _: { };
}
