# Runs for every zsh, scripts included. Keep tiny, no output.
export ZDOTDIR="$HOME/.config/zsh"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
source "$HOME/.rover/env"
. "$HOME/.cargo/env"
