# dotfiles

macOS terminal setup — zsh + oh-my-zsh + powerlevel10k, tmux, helix, ghostty — unified on the
**Frantic Contrast** (rainglow) palette ported from VS Code.

## Layout

| repo path | installed to |
|---|---|
| `zshenv` | `~/.zshenv` (sets `ZDOTDIR=~/.config/zsh`) |
| `zsh/{zshrc,zprofile,p10k.zsh,completions/}` | `~/.config/zsh/.zshrc` etc. |
| `tmux/tmux.conf`, `tmux/*.sh` | `~/.tmux.conf`, `~/.tmux/` |
| `helix/*` | `~/.config/helix/` |
| `ghostty/config`, `ghostty/themes/` | `~/.config/ghostty/` |
| `ghostty/config.app-support` | `~/Library/Application Support/com.mitchellh.ghostty/config` |
| `launchagents/*.plist` | `~/Library/LaunchAgents/` (rendered with real `$HOME`) |

## Install

```sh
git clone git@github.com:david-morgan-suffolk/dotfiles.git ~/projects/dotfiles
~/projects/dotfiles/install.sh
```

`install.sh` symlinks everything into place, backing up any existing regular files as `*.bak.<ts>`.

### Dependencies (Homebrew)

```sh
brew install tmux helix zoxide fzf uv powerlevel10k zsh-autosuggestions zsh-syntax-highlighting
brew install --cask ghostty font-meslo-lg-nerd-font
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

oh-my-zsh is a stock clone at `~/.oh-my-zsh`; nothing under `custom/` is used. Plugins are declared
in `zsh/zshrc`. powerlevel10k, autosuggestions and syntax-highlighting are sourced from Homebrew,
not from omz custom.

Regenerate completions after upgrading the tools:

```sh
just --completions zsh > ~/.config/zsh/completions/_just
databricks completion zsh > ~/.config/zsh/completions/_databricks
```

## Theme: Frantic Contrast

Ported from `daylerees.rainglow` VS Code theme. Dark only. Shared palette:

| role | hex |
|---|---|
| bg / fg | `#0e1114` / `#aeb9c4` |
| coral accent | `#ef6462` |
| steel blue | `#89a7bc` |
| lavender | `#968cea` / `#afa9e5` |
| green / yellow / red | `#a7da1e` / `#f7b83d` / `#e61f44` |
| comment / muted | `#44515e` / `#576a7d` |

- **ghostty**: `themes/frantic-contrast` — ANSI 16 widened from the theme's duotone so git/ls stay readable. `background-opacity 0.82`; `cmd+shift+b` toggles opaque.
- **tmux**: no theme plugin; all styles explicit in `tmux.conf`. `bg=default` everywhere so ghostty transparency shows through; `prefix+B` flips to opaque dimming.
- **helix**: `frantic_contrast` (opaque, bg matches ghostty opaque mode) and `frantic_contrast_transparent` (default). `sync-theme.sh` + LaunchAgent rewrite `config.toml` on macOS appearance change — both light/dark currently point at the transparent variant.

## Keybinds worth remembering

- tmux prefix `C-a`; `=` / `-` split; `h j k l` navigate; `H J K L` resize; `e` equalize; `9` / `0` prev/next session; `W` promote window to session; `B` opaque toggle; `r` reload
- ghostty `cmd+shift+o` float on top, `cmd+shift+b` opacity, global `cmd+\`` quick terminal
- helix `space+m` glow preview in tmux popup, `C-y` yazi
