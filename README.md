# dotfiles

configs and other shit.
 
## Install

```sh
git clone git@github.com:haitheredavid/dotfiles.git ~/projects/dotfiles
brew bundle --file ~/projects/dotfiles/Brewfile   # or DEPENDENCIES.md
~/projects/dotfiles/install.sh
~/projects/dotfiles/install-local.sh              # links to local checkouts (ctx presets, herdr plugins); skips missing ones
```
App replaced symlink with plain file → adopt back:

```sh
stow -d ~/projects/dotfiles -t ~ --no-folding --adopt claude omp herdr && git -C ~/projects/dotfiles diff
```

## Linux

`linux/setup.sh` is the Linux counterpart of the Brewfile + `install.sh`, for Ubuntu 24.04. It installs apt packages, plus helix, fzf, gh, bun, terraform and the aws CLI through mise, then runs `install.sh` and clones the oh-my-zsh prompt and line-editing addons. Run it as your user (it uses sudo for apt); it's idempotent. `.zshrc` only defines tool aliases (`tf`, `mux`, `oc`, the app shortcuts…) and the terraform/tmuxinator plugins where their tool is installed, so a machine without one has no dead alias.

`linux/Dockerfile` builds an image with all of it (copies this checkout, uncommitted changes included, to `~/projects/dotfiles` and, readable by everyone, to `/opt/dotfiles`). herdr-box builds on it and seeds homes that predate the image from `/opt/dotfiles`.

```sh
docker build -f linux/Dockerfile -t dotfiles . && docker run --rm -it dotfiles
linux/check.sh   # build + check a login zsh loads cleanly and finds its tools
```

## Theme

dark-tundra everywhere, accent soft burnt orange `#B87048` (brighter `#D4915E` for cursor, active labels, git status). Transparent backgrounds over ghostty `background-opacity 0.82`.

## Keys

- tmux / herdr prefix `C-a`; `=` / `-` split, `hjkl` move, `HJKL` resize
- herdr: `prefix+f` sessionizer, `cmd+k` herdr-bar, `prefix+alt+r` reload omz in idle panes
- tmux floats: `C-8` note, `C-9` omp, `C-0` shell
- helix: `space+m` mdview preview, `C-y` yazi
