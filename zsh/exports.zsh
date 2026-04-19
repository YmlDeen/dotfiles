# ╔══════════════════════════════════════════════════════╗
# ║  exports.zsh — environment variables                 ║
# ╚══════════════════════════════════════════════════════╝

# ── PATH ─────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── VAULT & KOS ──────────────────────────────────────────
export VAULT="/storage/emulated/0/Download/vault"
export NOTE_VAULT="$VAULT"
export NOTE_SH="$HOME/note.sh"
export KOS_ROOT="$HOME/kos"
export KOS_VAULT="$VAULT"
export KOS_INBOX="$VAULT/00-inbox"
export PATH="$KOS_ROOT:$PATH"

# ── EDITOR ───────────────────────────────────────────────
export EDITOR="nano"
export VISUAL="$EDITOR"

# ── LOCALE ───────────────────────────────────────────────
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ── TOOLS ────────────────────────────────────────────────
export CLICOLOR=1
export LESS="-R --quit-if-one-screen --no-init"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
