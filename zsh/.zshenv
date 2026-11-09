# Runs for every zsh, scripts included. Keep tiny, no output.
export ZDOTDIR="$HOME/.config/zsh"
export EDITOR="hx" VISUAL="hx"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
[[ -r "$HOME/.rover/env" ]] && source "$HOME/.rover/env"
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
