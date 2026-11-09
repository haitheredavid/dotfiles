# dotfiles

macOS terminal + agent setup — zsh + oh-my-zsh + powerlevel10k, tmux, tuios, helix, ghostty, herdr,
omp, Claude Code, shared agent skills — managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a stow package whose tree mirrors `$HOME`:

| package | installs |
|---|---|
| `zsh` | `~/.zshenv` (sets `ZDOTDIR=~/.config/zsh`), `~/.config/zsh/{.zshrc,.zprofile,.p10k.zsh,completions/}` |
| `tmux` | `~/.tmux.conf`, `~/.tmux/*.sh`, `~/.tmux/float.conf` |
| `helix` | `~/.config/helix/` |
| `ghostty` | `~/.config/ghostty/`, `~/Library/Application Support/com.mitchellh.ghostty/config` |
| `herdr` | `~/.config/herdr/config.toml` (sockets, logs, session state stay untracked). Claude hook from `herdr integration install claude` lives in `claude` (`hooks/herdr-agent-state.sh` + `settings.json` entry); rerun it after upgrading herdr |
| `tuios` | `~/Library/Application Support/tuios/{config.toml,themes/}`, `~/.local/bin/tuios-notes`; dock cells reuse `~/.tmux/{load,git-branch}.sh` |
| `omp` | `~/.omp/agent/config.yml`, `~/.omp/agent/extensions/` |
| `claude` | `~/.claude/{CLAUDE.md,settings.json,statusline-command.sh,hooks/}`, personal skills, links into `agents` skills |
| `agents` | `~/.agents/skills/` + `.skill-lock.json` (third-party skills from the `skills` CLI) |
| `markdown` | `~/.local/bin/mdview` + `~/.local/share/mdview/` (Chrome preview), `~/Library/Application Support/marksman/config.toml` |

Not tracked: app state/history/caches (incl. tuios `sessions/`, `sidebar.json`, `tape-trust.toml`), Claude plugins (reinstalled from `enabledPlugins` in
`settings.json`), databricks/mlflow skills (installed by their own tooling), tmux plugin checkouts
(the `@plugin` list lives in `tmux/.tmux.conf`; `install.sh` installs them via tpm).

## Install

```sh
git clone git@github.com:haitheredavid/dotfiles.git ~/projects/dotfiles
brew bundle --file ~/projects/dotfiles/Brewfile   # or DEPENDENCIES.md without Homebrew
~/projects/dotfiles/install.sh
```

`install.sh` moves anything already at a package path to `~/.dotfiles-backup/<ts>/`, then runs
`stow --no-folding --restow`, so every file is its own symlink and real directories like
`~/.claude` stay real. It also links ctx-scaffold presets from `~/suffolk/ctx` when present, and
clones oh-my-zsh and tpm if missing. Idempotent; re-run after adding a file to a package.

To have a coding agent do the whole setup (deps, clone, install, verification), paste
[AGENT_INSTALL.md](AGENT_INSTALL.md) into it.

Apps that save settings by replacing the file (Claude Code / omp settings UIs, herdr's settings
screen and onboarding, herdr integration installs) can swap a symlink for a plain file. Detect, then
pull the app's version into the repo and relink:

```sh
stow -n -d ~/projects/dotfiles -t ~ --no-folding -v claude omp herdr   # lists replaced files as conflicts
stow    -d ~/projects/dotfiles -t ~ --no-folding --adopt claude omp herdr && git -C ~/projects/dotfiles diff
```

### Dependencies

With Homebrew, uncomment the optional entries you want in [Brewfile](Brewfile), then:

```sh
brew bundle --file ~/projects/dotfiles/Brewfile
```

Without Homebrew, follow [DEPENDENCIES.md](DEPENDENCIES.md) (macOS arm64; installs into
`~/.local/bin` and each tool's standard home).

oh-my-zsh is a stock clone at `~/.oh-my-zsh` (cloned by `install.sh`; the official installer would
overwrite `.zshrc`). Plugins are declared in `.zshrc`. powerlevel10k, autosuggestions and
syntax-highlighting are sourced from Homebrew if present, else from
`~/.oh-my-zsh/custom/{themes,plugins}/`.

Regenerate completions after upgrading the tools:

```sh
just --completions zsh > ~/.config/zsh/completions/_just
databricks completion zsh > ~/.config/zsh/completions/_databricks
herdr completion zsh > ~/.config/zsh/completions/_herdr
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
- **helix**: `dark_tundra_transparent` (default) and `dark_tundra`, plus `frantic_contrast(_transparent)`. `tuios_terminal` uses only the 16 ANSI slots and the default background, so it follows whatever theme tuios/ghostty paints; switch to it when trying other tuios themes.
- **tuios**: `dark_tundra` (`themes/dark_tundra.json`: `frantic_contrast` palette with dark-tundra chrome — green accent, slate unfocused border), `background = "off"` so ghostty's opacity shows through, thin `normal` borders. Every dock, tab and selection colour is a theme role/ink (`accent`, `text`, `dim`, `muted`, `success`, `warning`, `surface`), so switching theme recolours the whole chrome. `rose_pine_iris` (Rose Pine with an iris accent) is kept as an alternative. Two rails: right `sessions:30,terminals,spacer`, left `agents,files:35`. `set-config` and the settings page edit the linked file in place, so changes land in the repo.

## Keybinds worth remembering

- tmux prefix `C-a`; `=` / `-` split; `h j k l` navigate; `H J K L` resize; `e` equalize; `9` / `0` prev/next session; `W` promote window to session; `A` claude agents sidebar; `B` opaque toggle; `r` reload
- tmux floating panels, no prefix: `C-8` new de-vault scratch note in helix (`people/david-morgan/scratch/`), `C-9` omp, `C-0` shell. The same key hides the panel (it keeps running) and brings it back; another panel key switches to that panel. They live on a separate `float` tmux server (`tmux -L float ls`)
- herdr prefix `C-s` (default `C-b`); `v` / `-` split; `c` new tab; `n` / `p` next/prev tab; `w` workspaces; `q` detach; `s` settings; `?` all bindings
- ghostty `cmd+shift+o` float on top, `cmd+shift+b` opacity, global `cmd+\`` quick terminal
- tuios prefix `C-a` (tmux preset, same splits/focus keys as tmux); `prefix+alt+o` omp scratch, `prefix+alt+n` notes picker, `prefix+alt+t` blank scratch terminal
- helix `space+m` previews the current file in Chrome (`mdview`, VS Code-style, live reload on save), `C-y` yazi
