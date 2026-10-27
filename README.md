# dotfiles

macOS terminal + agent setup — zsh + oh-my-zsh + powerlevel10k, tmux, helix, ghostty, omp, Claude
Code, shared agent skills — managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a stow package whose tree mirrors `$HOME`:

| package | installs |
|---|---|
| `zsh` | `~/.zshenv` (sets `ZDOTDIR=~/.config/zsh`), `~/.config/zsh/{.zshrc,.zprofile,.p10k.zsh,completions/}` |
| `tmux` | `~/.tmux.conf`, `~/.tmux/*.sh` |
| `helix` | `~/.config/helix/` |
| `ghostty` | `~/.config/ghostty/`, `~/Library/Application Support/com.mitchellh.ghostty/config` |
| `omp` | `~/.omp/agent/config.yml`, `~/.omp/agent/extensions/` |
| `claude` | `~/.claude/{CLAUDE.md,settings.json,statusline-command.sh,hooks/}`, personal skills, links into `agents` skills |
| `agents` | `~/.agents/skills/` + `.skill-lock.json` (third-party skills from the `skills` CLI) |
| `launchagents/` (not a package) | `~/Library/LaunchAgents/` (rendered with real `$HOME`) |

Not tracked: app state/history/caches, Claude plugins (reinstalled from `enabledPlugins` in
`settings.json`), databricks/mlflow skills (installed by their own tooling), tmux plugin checkouts
(the `@plugin` list lives in `tmux/.tmux.conf`; `install.sh` installs them via tpm). The sidebar
plugin uses `tree` and tome uses `nvim`/`vim` (`brew install tree neovim`).

## Install

```sh
brew install stow
git clone git@github.com:haitheredavid/dotfiles.git ~/projects/dotfiles
~/projects/dotfiles/install.sh
```

`install.sh` moves anything already at a package path to `~/.dotfiles-backup/<ts>/`, then runs
`stow --no-folding --restow`, so every file is its own symlink and real directories like
`~/.claude` stay real. It also renders the LaunchAgent, links ctx-scaffold presets from
`~/suffolk/ctx` when present, and clones oh-my-zsh and tpm if missing. Idempotent; re-run after
adding a file to a package.

Apps that save settings by replacing the file (Claude Code / omp settings UIs) can swap a symlink
for a plain file. Detect, then pull the app's version into the repo and relink:

```sh
stow -n -d ~/projects/dotfiles -t ~ --no-folding -v claude omp   # lists replaced files as conflicts
stow    -d ~/projects/dotfiles -t ~ --no-folding --adopt claude omp && git -C ~/projects/dotfiles diff
```

### Dependencies (Homebrew)

```sh
brew install stow tmux helix zoxide fzf uv powerlevel10k zsh-autosuggestions zsh-syntax-highlighting
brew install --cask ghostty font-meslo-lg-nerd-font
```

oh-my-zsh is a stock clone at `~/.oh-my-zsh` (cloned by `install.sh`; the official installer would
overwrite `.zshrc`); nothing under `custom/` is used. Plugins are declared in `.zshrc`.
powerlevel10k, autosuggestions and syntax-highlighting are sourced from Homebrew.

Regenerate completions after upgrading the tools:

```sh
just --completions zsh > ~/.config/zsh/completions/_just
databricks completion zsh > ~/.config/zsh/completions/_databricks
```

## Themes

ghostty and helix use **Frantic Contrast**, ported from the `daylerees.rainglow` VS Code theme. Dark only. Palette:

| role | hex |
|---|---|
| bg / fg | `#0e1114` / `#aeb9c4` |
| coral accent | `#ef6462` |
| steel blue | `#89a7bc` |
| lavender | `#968cea` / `#afa9e5` |
| green / yellow / red | `#a7da1e` / `#f7b83d` / `#e61f44` |
| comment / muted | `#44515e` / `#576a7d` |

- **ghostty**: `themes/frantic-contrast` — ANSI 16 widened from the theme's duotone so git/ls stay readable. `background-opacity 0.82`; `cmd+shift+b` toggles opaque.
- **tmux**: dark-tundra, matching omp's `theme.dark`; no theme plugin, all styles explicit in `.tmux.conf`. `bg=default` everywhere so ghostty transparency shows through; `prefix+B` flips to opaque dimming. Status bar on top.
- **helix**: `frantic_contrast` (opaque, bg matches ghostty opaque mode) and `frantic_contrast_transparent` (default). `sync-theme.sh` + LaunchAgent rewrite `config.toml` on macOS appearance change — both light/dark currently point at the transparent variant.

## Keybinds worth remembering

- tmux prefix `C-a`; `=` / `-` split; `h j k l` navigate; `H J K L` resize; `e` equalize; `9` / `0` prev/next session; `W` promote window to session; `A` claude agents sidebar; `B` opaque toggle; `r` reload
- ghostty `cmd+shift+o` float on top, `cmd+shift+b` opacity, global `cmd+\`` quick terminal
- helix `space+m` markless preview of the current file, `C-y` yazi
