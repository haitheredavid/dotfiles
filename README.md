# dotfiles

configs and other shit.
 
## Install

```sh
git clone git@github.com:haitheredavid/dotfiles.git ~/projects/dotfiles
brew bundle --file ~/projects/dotfiles/Brewfile   # or DEPENDENCIES.md
~/projects/dotfiles/install.sh
```
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
