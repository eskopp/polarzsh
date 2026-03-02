# polarzsh

A reproducible **Oh My Zsh** setup for Arch Linux with a managed minimal config, a custom Polar prompt theme, **zoxide** integration, and an installer/uninstaller that can bootstrap dependencies.

## What you get

- **Oh My Zsh** managed setup
- **polarzsh theme** (Polar-style prompt; git branch only inside repos)
- **zoxide** enabled automatically (smart `cd`)
- **Arch-friendly** installer:
  - installs required packages via `pacman` (if missing)
  - installs Oh My Zsh unattended (if missing)
  - links config/theme/plugin into the correct OMZ locations
- **Clean uninstaller**:
  - restores backed up `~/.zshrc` when available
  - can remove OMZ + zsh packages (Arch)

## Requirements

- Arch Linux
- Internet access (for installing Oh My Zsh if it is not present)
- `sudo` rights (for `pacman` installs/removals)

## Repository layout

```
polarzsh/
  install.sh
  uninstall.sh
  files/
    zshrc.minimal
  omz/
    custom/
      themes/
        polarzsh.zsh-theme
      plugins/
        polarzsh/
          polarzsh.plugin.zsh
```

## Install

From the repo directory:

```bash
cd ~/git/polarzsh
./install.sh
exec zsh -l
```

Notes:

- The installer **does not** change your login shell by default.
- If you want zsh as your default login shell:

```bash
chsh -s /usr/bin/zsh
```

This takes effect on next login / new terminal session.

## Uninstall

**Important:** do not run the uninstaller from an active zsh session if it removes zsh packages. Switch to bash first:

```bash
bash
cd ~/git/polarzsh
./uninstall.sh
```

The uninstaller will:
- remove polarzsh theme/plugin links
- restore `~/.zshrc` from backup (if present)
- remove `~/.oh-my-zsh` (if configured that way)
- optionally remove `zsh` and related packages on Arch (if configured that way)

## zoxide usage

zoxide is a smarter `cd`:

- Jump to frequently used directories:

```bash
z polarzsh
z git
```

- Interactive selection (works best if `fzf` is installed):

```bash
zi
```

## Oh My Zsh auto-update

This repo can configure OMZ updates via `zstyle` in `files/zshrc.minimal`, e.g.:

```zsh
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7
```

- `mode auto` updates automatically when due
- `frequency 7` limits it to once every 7 days (triggered on shell startup)

If you prefer reminders only:

```zsh
zstyle ':omz:update' mode reminder
```

## Customization

### Prompt / theme

Edit:

- `omz/custom/themes/polarzsh.zsh-theme`

Then re-apply links (optional) and reload:

```bash
cd ~/git/polarzsh
./install.sh
exec zsh -l
```

### Local machine overrides (not tracked)

Create:

- `~/.config/polarzsh/local.zsh`

It is sourced at the end of `files/zshrc.minimal` (if present). Put machine-specific PATH tweaks, aliases, env vars there.

## Troubleshooting

### “plugin '<name>' not found”

Oh My Zsh only loads plugins located in:
- `~/.oh-my-zsh/plugins/<name>` (built-in)
- `~/.oh-my-zsh/custom/plugins/<name>` (custom)

If a plugin is installed via pacman but not in those directories, it must be sourced directly (or vendored as a custom plugin). This repo keeps external integrations inside `polarzsh.plugin.zsh` when needed.

### Prompt looks wrong after `cd`

If another tool modifies `PROMPT` on directory changes (e.g., environment managers), ensure polarzsh is applied last by keeping prompt logic inside the theme and using a `precmd` hook there.

## License
MIT License

Copyright (c) 2026 Erik Skopp

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.