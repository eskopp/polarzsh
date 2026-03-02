#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="$HOME/.config/polarzsh/backups"
STATE_FILE="$BACKUP_DIR/install-state.env"

die() { echo "Error: $*" >&2; exit 1; }
info() { echo "[polarzsh] $*"; }

safe_rm_link() {
  local p="$1"
  if [[ -L "$p" ]]; then
    rm -f "$p"
    return 0
  fi
  return 0
}

restore_backup() {
  local zshrc="$1"
  local backup="$2"

  if [[ -n "$backup" && -e "$backup" ]]; then
    info "Restoring ~/.zshrc from backup: $backup"
    rm -f "$zshrc"
    cp -a "$backup" "$zshrc"
  else
    info "No ~/.zshrc backup found. Removing ~/.zshrc (if it's a symlink)..."
    if [[ -L "$zshrc" ]]; then
      rm -f "$zshrc"
    else
      info "~/.zshrc is not a symlink; leaving it untouched."
    fi
  fi
}

main() {
  [[ -f "$STATE_FILE" ]] || die "State file not found: $STATE_FILE (nothing to uninstall?)"

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
  restore_backup "${ZSHRC:-$HOME/.zshrc}" "${ZSHRC_BACKUP:-}"

  info "Keeping backups directory at: $BACKUP_DIR"
  info "Removing state file..."
  rm -f "$STATE_FILE"

  info "Done. Apply with: exec zsh"
}

main "$@"
