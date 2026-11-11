def npins_to_uris [path:path]: nothing -> list<string> {
    let pins = (open $path).pins | items {|_,val|
        if $val.url == null {
          # this most likely happens for raw git inputs
          $val.repository?.url?  
        } else {
            $val.url
        }
    }
    $pins
}

const MODES = [check test switch build]
def n [mode: string@[...$MODES], system?: string, ...flags]: nothing -> oneof<nothing,string> {
    let uris = npins_to_uris ./npins/sources.json
    let common_args = ["--extra-experimental-features" "pipe-operator" "--restrict-eval" "-I=./" "--allowed-uris" ($uris | str join ' ') "--no-allow-import-from-derivation"]

    if $mode not-in $MODES {
        error make {
            msg: $"invalid mode ($mode)"
        }
    }
    let system = if $system == "." { (uname).nodename } else { $system }
    let build_system = {|sys|
        let rev = ^git rev-parse HEAD
        ^nom-build ./system.nix --argstr rev $rev --attr $"($sys).config.system.build.toplevel" ...$common_args ...$flags |from json
    }
    let closure_info = {|c|nix path-info --json -Sh $c | from json | select  closureSize narSize path | into filesize closureSize narSize}
    let build_system_h = {|sys|
        let closure = $"/(do $build_system $system)"
        ^nix store diff-closures /run/current-system $closure
        print "Build derivation:"
        print (do $closure_info $closure)
        $closure
    }
    match $mode {
        "check" => {
            let rev = ^git rev-parse HEAD
            let systems: list<string> = if $system == null {
               #check all systems if none is specified
               ^nix eval --json --expr "builtins.attrNames (import ./system.nix {})" --impure | from json
            } else { [ $system ] };
            # potentially run checks in paralell
            print $"checking systems ($systems | str join ' ')"
            let _ = $systems | par-each {|system|
                let res = with-env {FORCE_COLOR: 1} {^nix eval --json --file ./system.nix --argstr rev $rev $"($system).config.system.build.toplevel" ...$common_args --impure ...$flags | complete }
                if $res.exit_code == 0 {
                    #filter `fetching `messages and control code lines
                    let warn = $res.stderr | lines | where $in !~ "fetching" | where ($in | str length) < 200 | length | $in > 0
                    if not $warn {
                        print $"($system): OK"
                    } else {
                        print $"($system): OK with warnings"
                        print -e -r $res.stderr
                    }
                } else {
                    print $"($system) failed:"
                    print -e -r $res.stderr
                }
            }
        }
        "build" => {do $build_system_h $system}
        _       => {
            let closure = do $build_system_h $system
            print $"Do you want to ($mode)?"
            let answer = [yes,no] | input list
            if $answer == "yes" {
                ^nixos-rebuild --elevate run0 --store-path $closure $mode ...$flags
            } else {
                print "aborting..."
            }
        }
    }
}
