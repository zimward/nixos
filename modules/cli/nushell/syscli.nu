const MODES = [check test switch build]
def RUNM [] { $MODES}

def n [mode: string@RUNM, system?: string, ...flags] {
    if $mode not-in $MODES {
        error make {
            msg: $"invalid mode ($mode)"
        }
    }
    match $mode {
        "check" => {
            if $system == null {
           ^nix eval --json -E "import ./system.nix |> builtins.attrNames" --impure | from json | each {|system|
                    print $"checking ($system)"
                    ^nix eval --json -E $"\(import ./system.nix\).($system).config.system.build.toplevel" --impure ...$flags | from json
                }
            } else {
                ^nix eval --json -E $"\(import ./system.nix\).($system).config.system.build.toplevel" --impure ...$flags | from json
            }
        }
        "build" => {^nixos-rebuild build --file ./system.nix --attr $system ...$flags}
        _       => {^run0 nixos-rebuild $mode --file ./system.nix --attr $system ...$flags}
    }
}
