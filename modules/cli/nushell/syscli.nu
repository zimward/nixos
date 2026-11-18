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

def split_string_at [sep: string]: string -> list<string> {
    let input = $in
    mut out: list<string> = []
    #first match
    mut last = 0
    loop {
        let idx = $input | str index-of $sep --range $last..
        if $idx == -1 {
            #append remaining
            $out = $out | append ($input | str substring $last..)
            break;
        }
        $out = $out | append ($input | str substring $last..($idx - 1))
        $last = $idx + 1
    }
    $out
}

const NDMODES = [shell build]
def nd [mode?: string@[...$NDMODES], file?: string, attr?: string, ...flags]: nothing -> oneof<nothing,string> {
    let mode = if $mode == null { "shell" } else { $mode }
    let file = if $file == null { "./shell.nix" } else { $file }

    let get_env_vars = {|file|
        # get all declare statements
        let kv_pairs = ^rg ^declare $file | lines | each {|it| $it | str replace "declare -x " "" | split_string_at "=" }
        $kv_pairs | each {|it|
            {
                name: $it.0,
                val: $it.1?
            }
        }
    }
    
    match $mode {
        "shell" => {
            # compare if expression file is newer than cached
            let expr = ls $file | select modified
            let prebuild = ls ./shell | select modified type
            if $prebuild.type.0 != "symlink" {
                error make {
                    msg: "file ./shell is not a symlink!"
                }
            }
            if $expr.modified <= $prebuild.modified {
                print "using cached shell file"
            } else {
                # expression changed. rebuild shell
                nix build --file $file -o ./shell
            }
            # TODO: maybe do everything in nushell instead of shelling out to bash
            # get env vars to set
            # let vars = do $get_env_vars ./shell
            # print $vars
            let tmp = mktemp -t -d "devshell-XXXXXXXX"
            let rc = $"($tmp)/rc"
            # extract all env var declares but exclude everything that references
            # /build as those change the shell path usually

            const exclude = [
                "\/build"
                "BASHOPTS"
                "HOME"
                "NIX_BUILD_TOP"
                "NIX_ENFORCE_PURITY"
                "NIX_LOG_FD"
                "NIX_REMOTE"
                "PPID"
                "SHELLOPTS"
                "TEMP"
                "TEMPDIR"
                "TERM"
                "TMP"
                "TMPDIR"
                "TZ"
                "UID"
            ] | str join "|"

            let _ = ^rg ^declare ./shell | rg -v $exclude | save -f $rc
            let declare = {|k,v| $"declare -x ($k)=\"($v)\"\n"}
            let tmpdirs = [ "TEMPDIR" "TMPDIR" "TEMP" "NIX_BUILD_TOP" "TMP" ]
            $tmpdirs | each {|d| do $declare $d $tmp } | str join | save -a $rc

            let restore = [ "PATH"  ]
            $env.PATH | prepend "$PATH" | str join ":" | do $declare "PATH" $in | save -a $rc

            ^bash --rcfile $rc
            rm $rc
        }
    }
}
