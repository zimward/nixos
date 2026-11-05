const MODES = [check test switch build]
def RUNM [] { $MODES}

def n [mode: string@RUNM, system?: string, ...flags] {
    if $mode not-in $MODES {
        error make {
            msg: $"invalid mode ($mode)"
        }
    }
    let build_system = {|sys| ^nom-build ./system.nix --attr $"($sys).config.system.build.toplevel" ...$flags |from json}
    let closure_info = {|c|nix path-info --json -Sh $c | from json | select  closureSize narSize path | into filesize closureSize narSize}
    let build_system_h = {|sys|
                            let closure = $"/(do $build_system $system)"
                            ^nix store diff-closures /run/current-system $closure
                            print "Build derivation:"
                            print (do $closure_info $closure)
                            echo $closure
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
        "build" => {let _ = do $build_system_h $system}
        _       => {
                    let closure = do $build_system_h $system
                    print $"Do you want to ($mode)?"
                    let answer = [yes,no] | input list
                    if $answer == "yes" {
                        ^run0 nixos-rebuild --store-path $closure $mode ...$flags
                    } else {
                        print "aborting..."
                    }
                }
    }
}
