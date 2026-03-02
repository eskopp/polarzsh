#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="$HOME/.config/polarzsh/backups"
STATE_FILE="$BACKUP_DIR/install-state.env"

die()  { echo "Error: $*" >&2; exit 1; }
info() { echo "[polarzsh] $*"; }

require_arch() {
  [[ -r /etc/arch-release ]] || die "This uninstaller is Arch-only. /etc/arch-release not found."
}

ensure_not_in_zsh() {
  # If the current shell process is zsh, abort to avoid breaking the running session.
  local comm
  comm="$(ps -p $$ -o comm= 2>/dev/null | tr -d ' ')"
  if [[ "${comm:-}" == "zsh" ]]; then
    die "You are currently running zsh. Run 'bash' first, then execute ./uninstall.sh again."
  fi
}

safe_rm_link() {
  local p="$1"
  [[ -n "$p" ]] || return 0
  if [[ -L "$p" ]]; then
    rm -f "$p"
  fi
}

restore_zshrc() {
  local zshrc="$1"
  local backup="$2"

  if [[ -n "$backup" && -e "$backup" ]]; then
    info "Restoring ~/.zshrc from backup: $backup"
    rm -f "$zshrc"
    cp -a "$backup" "$zshrc"
  else
    info "No ~/.zshrc backup found."
    if [[ -L "$zshrc" ]]; then
      info "Removing ~/.zshrc symlink..."
      rm -f "$zshrc"
    else
      info "~/.zshrc is not a symlink; leaving it untouched."
    fi
  fi
}

set_login_shell_bash_if_needed() {
  local current_shell
  current_shell="$(getent passwd "$USER" | cut -d: -f7 || true)"

  # Prefer /bin/bash, fallback to /usr/bin/bash
  local bash_path="/bin/bash"
  [[ -x "$bash_path" ]] || bash_path="/usr/bin/bash"

  # Must exist in /etc/shells
  if ! grep -qx "$bash_path" /etc/shells 2>/dev/null; then
    info "bash path '$bash_path' not listed in /etc/shells; skipping chsh."
    return 0
  fi

  if [[ "$current_shell" == *"zsh"* ]]; then
    info "Setting login shell back to bash ($bash_path)..."
    chsh -s "$bash_path"
    info "Login shell changed (effective next login)."
  fi
}

remove_omz_and_configs() {
  info "Removing Oh My Zsh and zsh config files..."
  rm -rf "$HOME/.oh-my-zsh" \
         "$HOME/.zprofile" "$HOME/.zshenv" "$HOME/.zlogin" "$HOME/.zlogout" \
         "$HOME/.config/zsh" "$HOME/.cache/zsh"
}

remove_zsh_packages_arch() {
  require_arch

  # Remove addons first (they depend on zsh), then zsh itself.
  local pkgs=(
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh
  )

  info "Removing zsh packages (sudo required)..."
  # -Rns: remove packages + unused deps + config files
  sudo pacman -Rns --noconfirm "${pkgs[@]}" 2>/dev/null || {
    info "Some packages were not installed or already removed; continuing."
  }
}

main() {
  ensure_not_in_zsh
  require_arch

  if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"

    info "Removing theme/plugin symlinks (if they are symlinks)..."
    safe_rm_link "${THEME_LINK:-}"
    safe_rm_link "${PLUGIN_LINK:-}"

    # Remove empty plugin directory if present
    if [[ -n "${CUSTOM_DIR:-}" && -d "$CUSTOM_DIR/plugins/polarzsh" ]]; then
      rmdir "$CUSTOM_DIR/plugins/polarzsh" 2>/dev/null || true
    fi

    info "Handling ~/.zshrc..."
    restore_zshrc "${ZSHRC:-$HOME/.zshrc}" "${ZSHRC_BACKUP:-}"
  else
    info "State file not found ($STATE_FILE). Proceeding with best-effort cleanup..."
    # Best effort: remove likely links
    safe_rm_link "$HOME/.oh-my-zsh/custom/themes/polarzsh.zsh-theme"
    safe_rm_link "$HOME/.oh-my-zsh/custom/plugins/polarzsh/polarzsh.plugin.zsh"
  fi

  set_login_shell_bash_if_needed
  remove_omz_and_configs
  remove_zsh_packages_arch

  info "Removing install state file..."
  rm -f "$STATE_FILE" 2>/dev/null || true

  info "Keeping backups directory at: $BACKUP_DIR"
  info "Done."
}

main "$@"
