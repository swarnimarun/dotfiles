if status is-interactive
    set --erase fish_greeting
    source ($HOME/.cargo/bin/starship init fish --print-full-init | psub)
    source "$HOME/.cargo/env.fish"

    set -gx PNPM_HOME $HOME/Library/pnpm
    set -gx HOMEBREW_PATH /opt/homebrew

    # remove on linux and wsl
    fish_add_path $HOMEBREW_PATH/bin
    fish_add_path $HOMEBREW_PATH/opt/openjdk/bin
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/.dotnet/tools
    fish_add_path $PNPM_HOME
    fish_add_path $PNPM_HOME

    set -gx EDITOR hx
    set -gx GPG_TTY (tty)
    set -gx CPPFLAGS -I/opt/homebrew/opt/openjdk/include

    alias nvim hx
    alias ls eza
    alias cat bat

    # The next line updates PATH for the Google Cloud SDK.
    bass source '$HOME/gcloud/path.bash.inc'

    # The next line enables shell command completion for gcloud.
    bass source '$HOME/gcloud/completion.bash.inc'

    source $HOME/.config/fish/.secrets.fish
end
