if status is-interactive
    source (starship init fish --print-full-init | psub)
end

fish_add_path $HOME/.local/bin
# setup cargo
fish_add_path $HOME/.cargo/bin

if test -d /opt/homebrew
    fish_add_path /opt/homebrew/bin
    set -gx DOTNET_ROOT /opt/homebrew/opt/dotnet/libexec
end

set -gx PNPM_HOME $HOME/Library/pnpm
set -gx GPG_TTY (tty)
fish_add_path $PNPM_HOME

if test -f /usr/lib/helix/hx
    set -gx EDITOR helix
    alias nvim helix
    alias hx helix
else if command -q hx
    set -gx EDITOR hx
    alias nvim hx
    alias helix hx
end

if test -d $HOME/gcloud
    # The next line updates PATH for the Google Cloud SDK.
    bass source $HOME/gcloud/google-cloud-sdk/path.bash.inc

    # The next line enables shell command completion for gcloud.
    bass source $HOME/gcloud/google-cloud-sdk/completion.bash.inc
end

# bun
set -gx BUN_INSTALL $HOME/.bun
set -gx PATH $BUN_INSTALL/bin:$PATH

# pull in the secrets; if they exist
if test -f ~/.config/fish/.secrets.fish
    source ~/.config/fish/.secrets.fish
end

# >>> JVM installed by coursier >>>
set -gx JAVA_HOME "/home/swarnim/.cache/coursier/arc/https/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.10%252B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.10_7.tar.gz/jdk-21.0.10+7"
set -gx PATH "$PATH:/home/swarnim/.cache/coursier/arc/https/github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.10%252B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.10_7.tar.gz/jdk-21.0.10+7/bin"
# <<< JVM installed by coursier <<<

# >>> coursier install directory >>>
set -gx PATH "$PATH:/home/swarnim/.local/share/coursier/bin"
# <<< coursier install directory <<<

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $PATH /home/swarnim/.ghcup/bin # ghcup-env