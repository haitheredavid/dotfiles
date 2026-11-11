# Enable Powerlevel10k instant prompt. Should stay close to the top of .zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---------- completions: fpath must be set BEFORE oh-my-zsh runs compinit ----------
fpath=("$ZDOTDIR/completions" "$HOME/.docker/completions" $fpath)
# $ZDOTDIR/completions holds hand-generated files for tools OMZ lacks a plugin for:
#   just --completions zsh > $ZDOTDIR/completions/_just
#   databricks completion zsh > $ZDOTDIR/completions/_databricks
#   herdr completion zsh > $ZDOTDIR/completions/_herdr
#   mise completion zsh > $ZDOTDIR/completions/_mise
# regenerate after upgrading those tools.

# ---------- oh-my-zsh ----------
export ZSH="$HOME/.oh-my-zsh"
# 'auto' ran a background git fetch on a timer and rewrote OMZ under you.
# 'reminder' only tells you an update exists; `omz update` applies it when you choose.
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 30   # days between checks (was 13)
plugins=(
  git             # gcmsg gco gp gl ga gaa gm gst grs gsta gstp gcl gwip gbda ...
  fzf             # ctrl-r fuzzy history, ctrl-t fuzzy files, alt-c fuzzy cd
  uv              # completions + uva uvr uvs uvx ...
  aws             # asp <profile> / agp, completions
  docker          # dps dpsa dex dlo dlog ... (add docker-compose plugin for dcup/dcdn)
  tmux tmuxinator # ta tl tksv; txs txo txl
  gh bun brew terraform gcloud   # completions (brew: bubu)
  zoxide          # z / zi
  sudo            # esc esc -> prepend sudo
  copypath        # copy cwd to clipboard
  extract         # x <archive>
  herdr           # herdr-ohmyzsh: hsplit htab hagent hworktree hreload, slow-command toasts
  alias-finder    # on-demand only: `alias-finder <cmd>` (autoload off, no nag)
)
# A command (or app path) that runs here. mise-managed tools count via their shims, which
# work before `mise activate` below. Plugins/aliases for tools a machine lacks (the Linux
# box has no tmuxinator or Mac apps) would only point at nothing, so they're skipped.
_has() { (( $+commands[$1] )) || [[ -x $1 || -x $HOME/.local/share/mise/shims/$1 ]]; }
for _p in terraform tmuxinator; do _has $_p || plugins=(${plugins:#$_p}); done; unset _p
source "$ZSH/oh-my-zsh.sh"          # runs compinit once; do not call it again below
# brew install puts zsh addons under /opt/homebrew/share; the no-brew install clones them into $ZSH/custom
_src_addon() { local f; for f in "$@"; do [[ -r "$f" ]] && { source "$f"; return; }; done; }
# ---------- prompt / theme ----------
_src_addon /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme "$ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
# To customize prompt, run `p10k configure` or edit $ZDOTDIR/.p10k.zsh.
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"

# ---------- PATH / tool homes ----------
# (ZDOTDIR, VOLTA_HOME, cargo, rover are in ~/.zshenv; brew, docker, obsidian in .zprofile)
[[ -r "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"   # uv / ~/.local/bin
export PATH="$BUN_INSTALL/bin:$PATH"
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
export PATH="$VOLTA_HOME/bin:$PATH"          # re-prepend so volta shims beat pnpm's bundled node
# node version: managed by volta. default `volta install node@22`, per-project `volta pin node@22`
# mise: per-directory tools/env from mise.toml / .tool-versions. Activated last so its tool paths
# win over everything above; it updates PATH on each prompt/cd (precmd + chpwd hooks).
# Leave node to volta: don't `mise use node` or the two will fight over which node is first.
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# ---------- env ----------
export OPENCODE_EXPERIMENTAL_WORKSPACES=true   # opencode git-worktree workspaces

#  ---------- aliases ----------
_has tmuxinator && alias mux='tmuxinator'
_has opencode && alias oc='opencode'
_has databricks && alias dbx='databricks'
_has terraform && alias tf='terraform'
_has claude && alias claudia='claude -p'
_has /Applications/Blender.app/Contents/MacOS/Blender && alias blender='/Applications/Blender.app/Contents/MacOS/Blender'
_has /Applications/love.app/Contents/MacOS/love && alias love='/Applications/love.app/Contents/MacOS/love'
_has csl && alias cm='csl multi && claude' cs='csl single && claude'
_has panoptes && alias pano='panoptes'
unfunction _has

# ---------- functions ----------
# svg [-c] [files...]: Quick Look (or Chrome with -c); no files → fzf pick under cwd
svg() {
  local chrome=0
  [[ $1 == -c ]] && { chrome=1; shift; }
  local -a files=("$@")
  (( $#files )) || files=("${(@f)$(fd -e svg | fzf -m)}")
  [[ -n ${files[1]} ]] || return 1
  if (( chrome )); then open -a "Google Chrome" "${files[@]}"
  else qlmanage -p "${files[@]}" &>/dev/null; fi
}
alias svgc='svg -c'

# mdc [files...]: render markdown with pandoc and open in Chrome; no files → fzf pick under cwd
mdc() {
  local -a files=("$@") htmls
  (( $#files )) || files=("${(@f)$(fd -e md | fzf -m)}")
  [[ -n ${files[1]} ]] || return 1
  local out="${TMPDIR:-/tmp}/mdc" f html
  mkdir -p "$out"
  for f in "${files[@]}"; do
    html="$out/${f:t:r}.html"
    pandoc -s --embed-resources --resource-path="${f:A:h}" \
      --metadata pagetitle="${f:t:r}" -o "$html" "$f" || return
    htmls+=("$html")
  done
  open -a "Google Chrome" "${htmls[@]}"
}

ipy(){
  local dir="${1:-.}"
  echo "# Init to win it" > "$dir/__init__.py"
}

cc-ultra() {
  claude --prompt "/caveman ultra" "$@"
}

# omp inside the paseo-env container, so sessions land where the Paseo daemon sees them.
# Only ~/projects and ~/suffolk are mounted (at identical paths).
ompc() {
  case "$PWD/" in
    "$HOME/projects/"*|"$HOME/suffolk/"*) ;;
    *) echo "ompc: $PWD is not mounted in the paseo container (~/projects, ~/suffolk only)" >&2; return 1 ;;
  esac
  local -a flags=(-i -u paseo -w "$PWD" -e TERM -e COLORTERM)
  [[ -t 0 && -t 1 ]] && flags+=(-t)
  docker exec "${flags[@]}" paseo omp "$@"
}

# touch + open in helix (creates parent dirs)
thx() {
  [[ -z "$1" ]] && { echo "usage: thx <path>" >&2; return 1; }
  mkdir -p "$(dirname "$1")" && touch "$1" && hx "$1"
}
alias hxn=thx   # old name

# new spec doc in ~/notes/de-vault/people/david-morgan/specs, seeded with the shared frontmatter
spec() {
  [[ -z "$1" ]] && { echo "usage: spec <title words>" >&2; return 1; }
  local dir="$HOME/notes/de-vault/people/david-morgan/specs"
  local name="${*%.md}.md"
  local file="$dir/$name"
  mkdir -p "$dir"
  if [[ ! -e "$file" ]]; then
    cat > "$file" <<EOF_SPEC
---
Type: Spec
Created: $(date +%F)
Status: draft
---
# ${*%.md}

## Context

## Spec
EOF_SPEC
  fi
  hx "$file"
}

# new markdown note: note [-l|--location sfk|hai|cwd] <title words>   (default: cwd)
note() {
  local -A opts
  zparseopts -D -E -A opts l: -location: || return 1
  local loc="${opts[-l]:-${opts[--location]:-cwd}}" dir
  case "$loc" in
    sfk) dir="$HOME/notes/de-vault/people/david-morgan/notes" ;;
    hai) dir="$HOME/notes/haithere/notes" ;;
    cwd) dir="$PWD" ;;
    *)   echo "note: unknown location '$loc' (sfk|hai|cwd)" >&2; return 1 ;;
  esac
  [[ -z "$1" ]] && { echo "usage: note [-l sfk|hai|cwd] <title words>" >&2; return 1; }
  local title="${*%.md}"
  local file="$dir/$title.md"
  mkdir -p "$dir"
  [[ -e "$file" ]] || printf -- '---\nCreated: %s\n---\n# %s\n\n' "$(date +%F)" "$title" > "$file"
  hx "$file"
}
compdef '_arguments "(-l --location)"{-l,--location}"[note location]:location:(sfk hai cwd)" "*:title: "' note

# browse a notes vault in yazi, cd to wherever you quit:
# notes [-l|--location sfk|hai|cwd] [path]   (default: hai; an explicit path wins)
notes() {
  local -A opts
  zparseopts -D -E -A opts l: -location: || return 1
  local loc="${opts[-l]:-${opts[--location]:-hai}}" dir
  case "$loc" in
    sfk) dir="$HOME/notes/de-vault" ;;
    hai) dir="$HOME/notes/haithere" ;;
    cwd) dir="$PWD" ;;
    *)   echo "notes: unknown location '$loc' (sfk|hai|cwd)" >&2; return 1 ;;
  esac
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi --cwd-file="$tmp" "${1:-$dir}"
  if cwd="$(<"$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
compdef '_arguments "(-l --location)"{-l,--location}"[notes location]:location:(sfk hai cwd)" "1:path:_files -/"' notes

# ---------- history (overrides oh-my-zsh lib/history.zsh, which must run first) ----------
HISTSIZE=50000
SAVEHIST=50000                 # OMZ caps this at 10000; keep the file as deep as the session
unsetopt share_history         # the big one: stop other terminals' commands landing in this one
setopt inc_append_history_time # still write each command immediately, just don't import theirs
setopt hist_ignore_all_dups    # keep only the newest copy of a repeated command
setopt hist_ignore_space       # a leading space keeps a command out of history entirely

# ---------- autosuggestions: contextual, not "whatever I typed once last month" ----------
# match_prev_cmd only suggests a line that previously followed the command you just ran,
# so suggestions track what you're actually doing; plain history is the fallback.
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=25          # stop suggesting once the line is long
ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'*\n*'      # never suggest a multi-line paste
ZSH_AUTOSUGGEST_MANUAL_REBIND=1             # skip the per-prompt widget rebind (faster)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#667381' # dimIce, less shouty

# ---------- completion behaviour ----------
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive, nothing fuzzier
zstyle ':completion:*' menu select                          # arrow-key menu instead of a wall
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{#B87048}%B%d%b%f'   # soft ember group headers
zstyle ':completion:*:warnings' format '%F{#D26B6B}no matches%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'

# ---------- line editing plugins (autosuggestions before highlighting; highlighting LAST) ----------
_src_addon /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
_src_addon /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unfunction _src_addon

# dark-tundra syntax colors (same palette as herdr/tmux/omp): soft ember for runnable words.
ZSH_HIGHLIGHT_STYLES[command]='fg=#B87048'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#B87048'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#B87048'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#B87048,underline'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#B87048'
ZSH_HIGHLIGHT_STYLES[function]='fg=#B87048'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#B87048,underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#D0B04D'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#D26B6B'
ZSH_HIGHLIGHT_STYLES[path]='fg=#E3E9F0,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#6C9FD6'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#D0B04D'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#D0B04D'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#D0B04D'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#667381'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#A3B0BF'

# accept just the next word of a suggestion instead of the whole line
bindkey '^[f' forward-word          # alt-f
bindkey '^[[1;5C' forward-word      # ctrl-right
