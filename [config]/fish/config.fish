if status is-interactive
    source (/Users/swarnimarun/.cargo/bin/starship init fish --print-full-init | psub)
    # remove on linux and wsl
    fish_add_path /opt/homebrew/bin
    fish_add_path $HOME/.cargo/bin

    set -gx PNPM_HOME /Users/swarnimarun/Library/pnpm
    set -gx EDITOR hx
    set -gx GPG_TTY (tty)
    fish_add_path $PNPM_HOME
    alias nvim hx

    # The next line updates PATH for the Google Cloud SDK.
    bass source '/Users/swarnimarun/gcloud/google-cloud-sdk/path.bash.inc'

    # The next line enables shell command completion for gcloud.
    bass source '/Users/swarnimarun/gcloud/google-cloud-sdk/completion.bash.inc'
end
