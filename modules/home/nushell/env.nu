# Nushell Environment Config File

def create_left_prompt [] {
    let path_segment = if (is-admin) {
        $"(ansi red_bold)($env.PWD)"
    } else {
        $"(ansi green_bold)($env.PWD)"
    }

    $path_segment
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | format  date '%m/%d/%Y %r')
    ] | str join)

    $time_segment
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = { "〉" }
$env.PROMPT_INDICATOR_VI_INSERT = { ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = { "〉" }
$env.PROMPT_MULTILINE_INDICATOR = { "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]



# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
$env.GTK_THEME = "Adwaita:dark"
$env.PATH = ($env.PATH | split row (char esep) | prepend '~/.local/bin:/opt/riscv32/bin:/opt/xpack/riscv-none-embed-gcc/bin:~/.cargo/bin:/var/lib/flatpak/exports/bin:~/.local/share/flatpak/exports/bin')
$env.STEAM_DIR = ($env.HOME | append '.steam' )
$env.EDITOR = 'helix'
$env.NNN_OPENER = '/home/modsog/.config/nnn/plugins/nuke'
$env.NNN_TMPFILE = '/tmp/nnn'
$env.MOZ_ENABLE_WAYLAND = 1
$env.LANG = "de_DE.utf-8"
$env.SSH_AUTH_SOCK = /run/user/1000/ssh-agent.socket
$env.CLIPPY_CONF_DIR = "/home/modsog/.config/clippy"
$env._JAVA_AWT_WM_NONREPARENTING = 1

#autostart sway
if  (not ($env | columns | any {|c| $c == DISPLAY })) and $env.XDG_VTNR? == "1" {
   #WLR_RENDERER=GLES sway
   sway
}
