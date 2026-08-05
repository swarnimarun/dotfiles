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
    set -gx DOTNET_ROOT $HOMEBREW_PATH/opt/dotnet/libexec
    fish_add_path $PNPM_HOME
    fish_add_path $PNPM_HOME

    set -gx EDITOR hx
    set -gx GPG_TTY (tty)
    set -gx CPPFLAGS -I/opt/homebrew/opt/openjdk/include

    alias nvim hx
    alias ls eza
    alias cat bat

    function clmac --description 'Run Claude Code with the prassoai profile'
        set -lx CLAUDE_CONFIG_DIR "$HOME/.config/claude-mac"
        # set -l profile "$HOME/.config/claude-mac"
        claude $argv
    end

    function comac --description 'Run Codex with the prassoai profile'
        set -lx CODEX_HOME "$HOME/.config/codex-mac"
        command codex $argv
    end

    function codex --description 'Run Codex with a directory-aware profile'
        if set -q CODEX_HOME
            command codex $argv
            return
        end
        set -l working_dir (pwd -P)
        if string match -q -- "$HOME/repos/github.com/prassoai" "$working_dir"; or string match -q -- "$HOME/repos/github.com/prassoai/"'*' "$working_dir"
            set -lx CODEX_HOME "$HOME/.config/codex-mac"
            command codex $argv
        else
            command codex $argv
        end
    end

    # Direct `claude` invocations use a repository profile when applicable,
    # otherwise an isolated, unsigned free profile. Callers that explicitly
    # set CLAUDE_CONFIG_DIR keep control of the selected profile.
    function claude --description 'Run Claude Code with a directory-aware profile'
        if set -q CLAUDE_CONFIG_DIR
            command claude $argv
            return
        end

        set -l working_dir (pwd -P)
        set -l profile "$HOME/.config/claude"
        if string match -q -- "$HOME/repos/github.com/prassoai" "$working_dir"; or string match -q -- "$HOME/repos/github.com/prassoai/"'*' "$working_dir"
            set profile "$HOME/.config/claude-mac"
        end
        set -lx CLAUDE_CONFIG_DIR "$profile"
        command claude $argv
    end

    # The next line updates PATH for the Google Cloud SDK.
    bass source '$HOME/gcloud/path.bash.inc'

    # The next line enables shell command completion for gcloud.
    bass source '$HOME/gcloud/completion.bash.inc'

    # bun
    set -gx BUN_INSTALL "$HOME/.bun"
    set -gx PATH "$BUN_INSTALL/bin:$PATH"

    # ghcup-env
    if test -f "$HOME/.ghcup/env"
        fish_add_path $HOME/.cabal/bin
        fish_add_path $HOME/.ghcup/bin
    end

    # pull in the secrets; if they exist
    if test -f ~/.config/fish/.secrets.fish
        source ~/.config/fish/.secrets.fish
    end
end
