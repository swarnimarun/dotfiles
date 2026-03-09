# env.nu
#
# Installed by:
# version = "0.107.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

alias nvim = hx

# Define PNPM Home
$env.PNPM_HOME = $"($env.USERPROFILE)\\AppData\\Local\\pnpm"

# Setup Cargo and Bun paths
let cargo_bin = $"($env.USERPROFILE)\\.cargo\\bin"
let bun_bin = $"($env.USERPROFILE)\\.bun\\bin"

# Update PATH (Windows uses a list internally in Nushell)
$env.PATH = (
    $env.PATH 
    | split row (char esep)
    | append $cargo_bin
    | append $env.PNPM_HOME
    | append $bun_bin
    | uniq
)

# GPG TTY equivalent (less critical on Windows, but good for consistency)
# $env.GPG_TTY = (tty)

# Setup Editor
if (which hx | is-not-empty) {
    $env.EDITOR = "hx"
}

# Bun Install root
$env.BUN_INSTALL = $"($env.USERPROFILE)\\.bun"

source 'C:\Users\swarn\AppData\Roaming\nushell\.secrets.nu'

