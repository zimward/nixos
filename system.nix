let
  inputs = (import ./inputs).inputs;
  inherit (inputs)
    nixpkgs
    nixpkgs-small
    ;
in
let
  # create a system configuration for a given host.
  mkSys = nixp: extraModules: name: {
    inherit name;
    value = nixp.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        secrets = import (inputs.secrets);
      };
      modules = [
        (./hosts + "/${name}/config.nix")
        ./modules
      ]
      ++ extraModules;
    };
  };

  # get a list of directories in a given path.
  filterAttrs =
    pred: set:
    removeAttrs set (builtins.filter (name: !pred name set.${name}) (builtins.attrNames set));
  getDirs = path: builtins.readDir path |> filterAttrs (n: v: v == "directory") |> builtins.attrNames;

  # Get the list of host directories.
  dirs = getDirs ./hosts;

  # determine if a host should use nixpkgs-small based on its configuration.
  isSmall =
    dir:
    let
      conf = import (./hosts + "/${dir}/config.nix");
      evaluated = (conf (builtins.functionArgs conf));
      config = evaluated.config or evaluated;
    in
    config.device.class == "server";

  # Map over the directories to determine which ones should use nixpkgs-small.
  small-checkout = map (d: {
    small = isSmall d;
    dir = d;
  }) dirs;

  # Get a list of directories that should use nixpkgs-small.
  small = map (s: s.dir) (builtins.filter (s: s.small) small-checkout);

  # Get a list of directories that should use the default nixpkgs.
  big = map (s: s.dir) (builtins.filter (s: !s.small) small-checkout);
  minimalProfile = (
    { modulesPath, ... }:
    {
      imports = [ "${modulesPath}/profiles/minimal.nix" ];
      disabledModules = [ ./modules/devices/desktop.nix ];
    }
  );
in
# Combine the configurations for all hosts into an attributes set, mapping each host to its respective system configuration.
builtins.listToAttrs (
  (map (mkSys nixpkgs [ inputs.cache-beacon.nixosModules.nix-cache-beacon ]) big)
  ++ (map (mkSys nixpkgs-small [
    minimalProfile
  ]) small)
)
