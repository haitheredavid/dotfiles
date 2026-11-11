# dotfiles

macOS terminal + agent setup: zsh/oh-my-zsh/p10k, tmux, herdr, helix, ghostty, omp, Claude Code, agent skills. Managed via [GNU Stow](https://www.gnu.org/software/stow/); each top-level dir = package mirroring `$HOME`.

## Install

```sh
git clone git@github.com:haitheredavid/dotfiles.git ~/projects/dotfiles
brew bundle --file ~/projects/dotfiles/Brewfile   # or DEPENDENCIES.md
~/projects/dotfiles/install.sh
```

`install.sh`: backs up conflicts to `~/.dotfiles-backup/<ts>/`, runs `stow --no-folding --restow`, clones oh-my-zsh + tpm, installs tmux plugins + herdr plugins (herdr-bar, sessionizer, ohmyzsh.shell; links local ctx.herdr-flow + panoptes if present). Idempotent. Agent-driven setup: paste [AGENT_INSTALL.md](AGENT_INSTALL.md).

App replaced symlink with plain file → adopt back:

```sh
stow -d ~/projects/dotfiles -t ~ --no-folding --adopt claude omp herdr && git -C ~/projects/dotfiles diff
```

## Theme

dark-tundra everywhere, accent burnt orange `#D9773A`. Transparent backgrounds over ghostty `background-opacity 0.82`.

## Keys

- tmux / herdr prefix `C-a`; `=` / `-` split, `hjkl` move, `HJKL` resize
- herdr: `prefix+f` sessionizer, `cmd+k` herdr-bar, `prefix+alt+r` reload omz in idle panes
- tmux floats: `C-8` note, `C-9` omp, `C-0` shell
- helix: `space+m` mdview preview, `C-y` yazi