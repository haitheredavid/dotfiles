# Runs for every zsh, scripts included. Keep tiny, no output.
export ZDOTDIR="$HOME/.config/zsh"
export EDITOR="hx" VISUAL="hx"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
[[ -r "$HOME/.rover/env" ]] && source "$HOME/.rover/env"
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
# Linux (linux/setup.sh): mise-managed CLIs (fzf, hx, gh, bun) on PATH before .zshrc loads
# oh-my-zsh, as `brew shellenv` does on the Mac.
[[ $OSTYPE == linux* && -d "$HOME/.local/share/mise/shims" ]] && export PATH="$HOME/.local/share/mise/shims:$PATH"
