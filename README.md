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

`linux/Dockerfile` builds an image with all of it (copies this checkout, uncommitted changes included, to `~/dotfiles`).

```sh
docker build -f linux/Dockerfile -t dotfiles . && docker run --rm -it dotfiles
linux/check.sh   # build + check a login zsh loads cleanly and finds its tools
```

## Theme

dark-tundra everywhere, accent soft burnt orange `#B87048` (brighter `#D4915E` for cursor, active labels, git status). Transparent backgrounds over ghostty `background-opacity 0.82`.

## Claude subscription

Default, planning, and review roles use `claude-bridge/claude-opus-5-5` through the installed `omp-agent-sdk-bridge` plugin. Planning and review retain high thinking effort. Log in through Claude Code (`claude`, then `/login`), not OMP's native Anthropic provider.

`omp/.omp/agent/claude-bridge.json` enforces subscription-only billing and disables Extra Usage. Credentials stay in Claude Code, outside dotfiles. Restart OMP after changing model roles; the native `anthropic/…` provider is separate and is not selected by these roles.

## Headroom UI

`omp/.omp/agent/extensions/headroom-ui.ts` adapts the linked Headroom plugin's widget into one full-width, title-free line of metrics, using the editor's theme symbols and aligned corners (`+` with the ASCII preset). Narrow terminals truncate rather than wrap. Headroom still owns all counters and refreshes; the adapter only replaces its framed string widget, leaving other widgets untouched. Enable the plugin with `omp plugin enable omp-headroom`, then restart OMP to load the extension.

## Keys

- tmux / herdr prefix `C-a`; `=` / `-` split, `hjkl` move, `HJKL` resize
- herdr: `prefix+f` sessionizer, `cmd+k` herdr-bar, `prefix+alt+r` reload omz in idle panes
- tmux floats: `C-8` note, `C-9` omp, `C-0` shell
- helix: `space+m` mdview preview, `C-y` yazi
