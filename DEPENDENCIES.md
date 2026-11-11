# Dependencies without Homebrew

The non-Homebrew counterpart of [Brewfile](Brewfile), for macOS on Apple Silicon (`uname -sm` →
`Darwin arm64`; release asset names below are arm64). Work top to bottom in one shell. Skip a row
if its tool is already on `PATH`. Binaries go to `~/.local/bin` unless the row says otherwise.

Commands inside tables write `|` as `\|` (Markdown escaping); type a plain `|`.

## Prerequisites

| tool | used by | install without Homebrew |
|---|---|---|
| git, make, cc | clone, source builds | `xcode-select --install` |
| `~/.local/bin` + `~/.local/bin/env` | every row below; `.zshrc` sources the env file if present | see block below |

`.zshrc` puts `~/.local/bin` on `PATH` only by sourcing `~/.local/bin/env`. The uv installer writes
that file only while it also appends to your rc files (including the stowed `~/.zshenv`), so
install uv with `UV_NO_MODIFY_PATH=1` (row below) and write the env file yourself:

```sh
mkdir -p ~/.local/bin
cat > ~/.local/bin/env <<'EOF'
#!/bin/sh
# add binaries to PATH if they aren't added yet
case ":${PATH}:" in
    *:"$HOME/.local/bin":*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
. ~/.local/bin/env
```

GitHub-release rows use this helper (prints the latest release asset URL matching a regex):

```sh
rel() { curl -fsSL "https://api.github.com/repos/$1/releases/latest" | jq -r --arg p "$2" '.assets[] | select(.name|test($p)) | .browser_download_url'; }
```

## Required

jq comes first because `rel` needs it.

| tool | used by | install without Homebrew |
|---|---|---|
| jq | `rel`, claude statusline / hooks | `curl -fsSLo ~/.local/bin/jq https://github.com/jqlang/jq/releases/latest/download/jq-macos-arm64 && chmod +x ~/.local/bin/jq` |
| uv | omz uv plugin, `uv tool` rows | `curl -LsSf https://astral.sh/uv/install.sh \| env UV_NO_MODIFY_PATH=1 sh` |
| stow | `install.sh` | `d=$(mktemp -d) && curl -fsSL https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz \| tar -xz -C "$d" && (cd "$d"/stow-* && ./configure -q --prefix="$HOME/.local" && make install)` (uses system perl) |
| tmux | terminal multiplexer | build from source, block below ([tmux wiki](https://github.com/tmux/tmux/wiki/Installing)); or `sudo port install tmux` if MacPorts is present |
| helix | editor (`hx`) | `d=$(mktemp -d) && curl -fsSL "$(rel helix-editor/helix 'aarch64-macos\.tar\.xz$')" \| tar -xJ -C "$d" && cp "$d"/helix-*/hx ~/.local/bin/ && mkdir -p ~/.config/helix/runtime && cp -R "$d"/helix-*/runtime/. ~/.config/helix/runtime/` |
| herdr | terminal multiplexer for agents | `curl -fsSLo ~/.local/bin/herdr "$(rel herdrdev/herdr '^herdr-macos-aarch64$')" && chmod +x ~/.local/bin/herdr` |
| bun | builds herdr sessionizer plugin (`install.sh` installs herdr plugins) | `curl -fsSL https://bun.sh/install \| bash` |
| zmx | herdr scratchpads (ctx.herdr-flow `prefix+t`) | see [neurosnap/zmx](https://github.com/neurosnap/zmx) (Homebrew: `neurosnap/tap/zmx`) |
| neovim | `$EDITOR` | `curl -fsSL "$(rel neovim/neovim '^nvim-macos-arm64\.tar\.gz$')" \| tar -xz -C ~/.local && ln -sf ~/.local/nvim-macos-arm64/bin/nvim ~/.local/bin/nvim` |
| zoxide | omz zoxide plugin (`z`, `zi`) | `curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \| sh` |
| fzf | omz fzf plugin, tmux-fzf | `git clone --depth 1 https://github.com/junegunn/fzf ~/.fzf && ~/.fzf/install --bin && ln -sf ~/.fzf/bin/fzf ~/.local/bin/fzf` |
| gh | claude statusline / hooks | `d=$(mktemp -d) && curl -fsSLo "$d/gh.zip" "$(rel cli/cli '_macOS_arm64\.zip$')" && unzip -q "$d/gh.zip" -d "$d" && cp "$d"/gh_*/bin/gh ~/.local/bin/` |
| yazi | helix `C-y`, `notes` | `d=$(mktemp -d) && curl -fsSLo "$d/yazi.zip" "$(rel sxyazi/yazi '^yazi-aarch64-apple-darwin\.zip$')" && unzip -q "$d/yazi.zip" -d "$d" && cp "$d"/yazi-aarch64-apple-darwin/{yazi,ya} ~/.local/bin/` |
| just | task runner, `_just` completions | `curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \| bash -s -- --to ~/.local/bin` |
| mise | per-project tool versions / env (`.zshrc`), `_mise` completions | `curl -fsSL https://mise.run \| MISE_INSTALL_PATH=~/.local/bin/mise sh` |
| tmuxinator | `mux` | `gem install --user-install --no-document tmuxinator && ln -sf "$(ruby -e 'puts Gem.user_dir')/bin/tmuxinator" ~/.local/bin/tmuxinator` (system ruby) |
| ghostty | terminal | `d=$(mktemp -d) && curl -fsSLo "$d/Ghostty.dmg" "$(curl -fsSL https://ghostty.org/download \| grep -oE 'https://release\.files\.ghostty\.org/[^"]*/Ghostty\.dmg' \| head -1)" && hdiutil attach -nobrowse "$d/Ghostty.dmg" && cp -R /Volumes/Ghostty/Ghostty.app /Applications/ && hdiutil detach /Volumes/Ghostty` (or the DMG from https://ghostty.org/download) |
| MesloLGS NF | ghostty `font-family`, p10k glyphs | `for s in Regular Bold Italic 'Bold Italic'; do curl -fsSLo ~/Library/Fonts/"MesloLGS NF $s.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${s// /%20}.ttf"; done` |
| marksman | helix markdown LSP | `curl -fsSLo ~/.local/bin/marksman "$(rel artempyanykh/marksman '^marksman-macos$')" && chmod +x ~/.local/bin/marksman` |
| deno | `mdview` (helix `space+m`) | `d=$(mktemp -d) && curl -fsSLo "$d/deno.zip" "$(rel denoland/deno '^deno-aarch64-apple-darwin\.zip$')" && unzip -oq "$d/deno.zip" deno -d ~/.local/bin` |
| Google Chrome | `mdview` | `curl -fsSLo /tmp/chrome.dmg https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg && hdiutil attach -nobrowse /tmp/chrome.dmg && cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/ && hdiutil detach "/Volumes/Google Chrome"` |

The helix runtime copy merges into `~/.config/helix/runtime`, which also holds the repo's stowed
`queries/mdx/*.scm` links; the release runtime has no `queries/mdx`, so those links survive.

tmux from source (libevent linked statically; macOS ships ncurses):

```sh
d=$(mktemp -d) && P="$d/deps"
curl -fsSL "$(rel libevent/libevent 'stable\.tar\.gz$')" | tar -xz -C "$d"
curl -fsSL "$(rel tmux/tmux '^tmux-.*\.tar\.gz$')" | tar -xz -C "$d"
(cd "$d"/libevent-* && ./configure -q --prefix="$P" --disable-openssl --disable-shared && make -s install)
(cd "$d"/tmux-* && ./configure -q --prefix="$HOME/.local" --disable-utf8proc --disable-jemalloc \
  CPPFLAGS="-I$P/include" LDFLAGS="-L$P/lib" && make -s install)
```

### After `install.sh` (needs `~/.oh-my-zsh`, which `install.sh` clones)

`.zshrc` sources these from Homebrew if present, else from `~/.oh-my-zsh/custom`.

| tool | used by | install without Homebrew |
|---|---|---|
| powerlevel10k | prompt | `git clone --depth=1 https://github.com/romkatv/powerlevel10k "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"` |
| zsh-autosuggestions | line editing | `git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"` |
| zsh-syntax-highlighting | line editing | `git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"` |

## Optional

Mirrors the commented entries in `Brewfile`.

| tool | used by | install without Homebrew |
|---|---|---|
| ruff | helix python formatter/LSP | `uv tool install ruff` |
| ty | helix python type checker | `uv tool install ty` |
| lua-language-server | helix lua | `mkdir -p ~/.local/lua-language-server && curl -fsSL "$(rel LuaLS/lua-language-server 'darwin-arm64\.tar\.gz$')" \| tar -xz -C ~/.local/lua-language-server && printf '#!/bin/sh\nexec "$HOME/.local/lua-language-server/bin/lua-language-server" "$@"\n' > ~/.local/bin/lua-language-server && chmod +x ~/.local/bin/lua-language-server` |
| terraform | helix hcl formatter, `tf` | `v=$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform \| jq -r .current_version) && d=$(mktemp -d) && curl -fsSLo "$d/tf.zip" "https://releases.hashicorp.com/terraform/$v/terraform_${v}_darwin_arm64.zip" && unzip -oq "$d/tf.zip" terraform -d ~/.local/bin` |
| awscli | omz aws plugin | `curl -fsSLo /tmp/AWSCLIV2.pkg https://awscli.amazonaws.com/AWSCLIV2.pkg && sudo installer -pkg /tmp/AWSCLIV2.pkg -target /` (sudo) |
| databricks CLI | `dbx`, `_databricks` completions | `curl -fsSL "$(rel databricks/cli 'darwin_arm64\.tar\.gz$')" \| tar -xz -C ~/.local/bin databricks` (the official `setup-cli` script writes to `/usr/local/bin` and needs sudo) |
| gcloud | omz gcloud plugin | `curl -fsSL https://sdk.cloud.google.com \| bash -s -- --disable-prompts --install-dir="$HOME"` (installs `~/google-cloud-sdk`) |
| Docker Desktop | omz docker plugin, `~/.docker/bin` | `curl -fsSLo /tmp/Docker.dmg https://desktop.docker.com/mac/main/arm64/Docker.dmg && sudo hdiutil attach -nobrowse /tmp/Docker.dmg && sudo /Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license && sudo hdiutil detach /Volumes/Docker` (sudo) |

### Toolchains with env files

`~/.zshenv` sources `~/.cargo/env` and `~/.rover/env`, and `.zshrc`/`.zshenv` put `~/.volta/bin` on
`PATH`, each only if present; install only the ones you use.

| tool | used by | install without Homebrew |
|---|---|---|
| Volta + Node | node/npm/pnpm (`~/.volta`) | `curl https://get.volta.sh \| bash -s -- --skip-setup && ~/.volta/bin/volta install node@22` |
| rustup | `~/.cargo/env` | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh -s -- -y --no-modify-path` |
| Rover | `~/.rover/env` | `curl -sSL https://rover.apollo.dev/nix/latest \| sh` |
