let-env ENV_CONVERSIONS = {
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
# By default, <nushell-config-dir>/scripts is added
let-env NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

if (sys | get host | get name) == "Windows" {
    # To add entries to PATH (on Windows you might use Path), you can use the following pattern:
    let-env Path = ($env.Path | split row (char esep) | prepend ((rustup which rust-analyzer) | path dirname) | prepend C:\Users\swarn\source\repos\zls\zig-out\bin)
} else {
    # let-env PATH = ($env.PATH | split row (char esep) | prepend "stuff")
}

# setup starship for nu
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu 

alias hxd = hx .
alias vi = hx
alias vim = vi

alias hxc = hx C:\Users\swarn\AppData\Roaming\helix\config.toml
alias hxl = hx C:\Users\swarn\AppData\Roaming\helix\languages.toml

alias pwd = $env.PWD
alias appdata = $env.APPDATA

def-env mkd [file] {
  mkdir -v $file
  cd $file
}

alias hxnue = hx $nu.env-path
alias hxnuc = hx $nu.config-path
alias hxwez = hx C:\Users\swarn\.wezterm.lua

alias pn = pnpm

alias l = exa -lahb
alias ls = exa
alias ll = exa -lhb
alias li = exa -lahb --git-ignore -I .git
alias lit = exa -lahbT --git-ignore -I .git

alias code = code-insiders

alias gcl = git clone
alias gcr = git clone --recursive
alias gc1 = git clone --depth=1

alias gco = git checkout

alias gcm = git commit -m
alias gca = git commit --amend

alias gl = git log
alias go = git log --oneline

alias gs = git show
alias gst = git status

alias gd = git diff
alias gdc = git diff --cached

alias gos = git log --oneline --show-signature

alias gu = gitui

alias gp =  git pull --ff 
alias gpr =  git pull --rebase 

alias gpu =  git push --help 

# def gpp [...args, ...flags] {
#   git pull --ff;
#   git push $args $flags
# }

# def gprp [...args, ...flags] {
#   git pull --rebase;
#   git push $args $flags
# }

def wcc [] {
   split chars | length
}

def wcl [] {
   lines | length
}

alias nvimc = nvim ($env.LOCALAPPDATA | path join "nvim")

# =============================================================================
#
# Add this to your env file (find it by running `$nu.env-path` in Nushell):
#
# zoxide init nushell | save -f ~/.zoxide.nu
#
# Now, add this to the end of your config file (find it by running
# `$nu.config-path` in Nushell):
#
source ~/.zoxide.nu
#
# Note: zoxide only supports Nushell v0.73.0 and above.

