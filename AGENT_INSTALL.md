# Agent install prompt

Paste everything below the line into a coding agent (Claude Code, omp, opencode, …) running in a
terminal on the target Mac. The agent needs shell access; nothing else is assumed to be installed.

---

You are setting up my macOS terminal + agent environment from my dotfiles repo
`https://github.com/haitheredavid/dotfiles` (GNU Stow packages: zsh + oh-my-zsh + powerlevel10k,
tmux, tuios, helix, ghostty, omp, Claude Code, shared agent skills). Work through the phases in order.
Run commands yourself; only stop to ask me where this prompt says **ASK**.

## Ground rules

- Never delete user files. `install.sh` moves anything it would replace into
  `~/.dotfiles-backup/<timestamp>/`; let it do that rather than removing things yourself.
- Never read or print secrets: `~/.ssh/*` private keys, `~/.aws/credentials`, `~/.databrickscfg`,
  `.env` files, tokens.
- Do not edit files inside the dotfiles repo unless I approve it; propose the diff instead.
- Before any `sudo` command or any GUI/password prompt (Homebrew install, Xcode CLT, `.pkg`
  installers), tell me what is about to happen.
- Every step is idempotent; if something is already installed, skip it and say so.
- If a command fails, show the error, diagnose it, and fix it or **ASK**. Do not skip silently.

## Phase 1 — Preflight

1. Confirm macOS on Apple Silicon (`uname -sm` → `Darwin arm64`). The no-Homebrew path in
   `DEPENDENCIES.md` downloads arm64 release assets; on Intel, **ASK** before continuing.
2. Check for Xcode Command Line Tools (`xcode-select -p`); install with `xcode-select --install`
   if missing and wait for me to finish the dialog. This provides `git`, needed to clone.
3. Record the current state for the final report: login shell (`echo $SHELL`), whether `~/.zshrc`,
   `~/.zshenv`, `~/.tmux.conf`, `~/.config/{zsh,helix,ghostty}`, `~/.claude`, `~/.omp` exist, and
   whether `brew` is on `PATH`.
4. **ASK** me:
   - Homebrew (recommended) or no Homebrew? If Homebrew and it is missing, install it from
     https://brew.sh, then `eval "$(/opt/homebrew/bin/brew shellenv)"` in your shell.
   - Clone location (default `~/projects/dotfiles`), and whether to clone over SSH
     (`git@github.com:haitheredavid/dotfiles.git`, needs a GitHub SSH key) or HTTPS
     (`https://github.com/haitheredavid/dotfiles.git`, read-only). If I'm using my own fork, use
     that URL.
   - Which packages to install (default all): `zsh tmux helix ghostty tuios omp claude agents markdown`.

## Phase 2 — Clone

Clone to the chosen location (`<repo>` below). If the directory already exists and is this repo,
`git pull --ff-only` instead.

## Phase 3 — Dependencies

Show me the optional entries and **ASK** which to enable: the commented lines under `# Optional`
in `<repo>/Brewfile` (the same tools as the Optional and "Toolchains with env files" tables in
`<repo>/DEPENDENCIES.md`), plus the extras table below.

### Homebrew path

Never edit the tracked `Brewfile`. Uncomment the chosen optional lines in a temp copy:

```sh
cp <repo>/Brewfile "$TMPDIR/Brewfile"
# uncomment the chosen optional lines (and their `tap` lines) in "$TMPDIR/Brewfile"
brew bundle --file "$TMPDIR/Brewfile"
```

Formulae from third-party taps (`hashicorp/tap`, `databricks/tap`) may be refused as untrusted;
tell me, then run `brew trust --formula <tap>/<formula>` and retry. Toolchains with env files
(Volta, rustup, Rover) have no Brewfile entry; install the chosen ones with the commands in
`DEPENDENCIES.md`.

Also write `~/.local/bin/env` as in the Prerequisites section of `DEPENDENCIES.md` (Homebrew's uv
does not create it); `.zshrc` sources it to put `~/.local/bin` on `PATH`, where installers such as
Claude Code's native one put binaries.

### No-Homebrew path

Execute `<repo>/DEPENDENCIES.md` top to bottom: Prerequisites, Required, and the Optional rows I
chose. Keep `~/.local/bin` on `PATH` for the rest of the session (`. ~/.local/bin/env`). Skip rows
whose tool is already on `PATH`. Defer the three `~/.oh-my-zsh/custom` clones to Phase 6.

### Extras (either path, only what I opted into)

| for | install |
|---|---|
| pnpm | `volta install pnpm` |
| bun | `curl -fsSL https://bun.sh/install \| bash` |
| helix TS/JS/ESLint LSPs | `npm i -g @vtsls/language-server vscode-langservers-extracted` |
| helix MDX LSP | `npm i -g @mdx-js/language-server` |
| Claude Code | `npm i -g @anthropic-ai/claude-code` (or the native installer) |
| omp | **ASK** me for the install method |

## Phase 4 — Dry run

```sh
stow -n -d <repo> -t ~ --no-folding -v <packages>
```

Summarise the conflicts (existing files that will be backed up). If any of them look like real
customisations rather than defaults (e.g. a large existing `~/.zshrc` or `~/.claude/settings.json`),
list them and **ASK** before proceeding.

## Phase 5 — Install

1. `install.sh` installs every package in its `PACKAGES=(...)` line. If I chose a subset,
   **ASK** before temporarily editing that line, and `git checkout install.sh` afterwards.
2. Run `<repo>/install.sh`. It:
   - backs up anything already at a package path to `~/.dotfiles-backup/<ts>/`,
   - runs `stow --no-folding --restow` (one symlink per file; real dirs like `~/.claude` stay real),
   - links ctx-scaffold presets from `~/suffolk/ctx/presets` only if that checkout exists (it
     usually won't on a new machine; that's fine),
   - clones oh-my-zsh to `~/.oh-my-zsh` (stock clone; do **not** run the official OMZ installer,
     it overwrites `.zshrc`),
   - clones tpm and installs the tmux plugins listed in `.tmux.conf`.
3. If the login shell isn't zsh: `chsh -s /bin/zsh` (tell me first; it prompts for a password).

## Phase 6 — Post-install addons (no-Homebrew path only)

Run the three clones in the "After `install.sh`" table of `<repo>/DEPENDENCIES.md`
(powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting into `~/.oh-my-zsh/custom`). `.zshrc`
sources the Homebrew copies when present, else these.

## Phase 7 — Machine-specific notes

Check each, report what you found, and propose fixes rather than editing tracked files:

- `.zshrc` sets `EDITOR=nvim` and defines personal helpers (`spec`, `note`, `notes`) that point at
  `~/notes/de-vault` and `~/notes/haithere`. They are harmless until called; just mention them.
- `claude/.claude/settings.json` hooks call `paseo` only when `PASEO_TERMINAL_ID` is set; no action
  needed unless I use paseo.
- Claude plugins are not tracked; they reinstall from `enabledPlugins` in `settings.json` on the
  next Claude Code launch (the `caveman` marketplace is declared there too).

## Phase 8 — Verify

Run each and report pass/fail with the actual output on failure:

1. `script -q /dev/null zsh -i -c 'echo ZDOTDIR=$ZDOTDIR; command -v z fzf hx tmux'` prints
   `ZDOTDIR=$HOME/.config/zsh` and a path for each tool.
2. `script -q /dev/null zsh -i -c exit 2>&1 | cat -v` shows no error text (a stray `^D` is fine).
   It runs under a pseudo-TTY, because without one zle and p10k's gitstatus print harmless
   errors; any other output means `.zshenv`/`.zshrc` sourced something that failed.
3. `stow -n -d <repo> -t ~ --no-folding -v <packages>` reports no conflicts. If omp or Claude
   Code has already been launched, it may have replaced a linked file with a plain one (e.g. a
   settings file rewritten by the app's settings UI); follow the `--adopt` steps in the repo README
   and show me the resulting `git diff`.
4. `readlink ~/.zshenv ~/.tmux.conf ~/.config/helix/config.toml ~/.tmux/copy-help/copy-help.tmux`
   all point into the repo.
5. `tmux -f ~/.tmux.conf new-session -d -s dotcheck && tmux kill-session -t dotcheck` succeeds,
   and `ls ~/.tmux/plugins` lists the plugins.
6. `hx --health` — list which configured language servers are missing (expected for anything I
   skipped in Phase 3).
7. `ls ~/Library/Fonts | grep -i meslo` finds the font.

## Phase 9 — Report

Finish with:

- what was installed, skipped (and why), and already present, and which path (Homebrew or not),
- the backup directory path and what it contains,
- verification results,
- proposed diffs for anything in Phase 7 that applies,
- manual steps left for me: open a new Ghostty window (or `cmd+shift+,` to reload config), run
  `p10k configure` only if the prompt looks wrong, sign in to `gh auth login` / Claude Code / omp.
