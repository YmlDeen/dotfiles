# ╔══════════════════════════════════════════════════════╗
# ║  aliases.zsh — all aliases                           ║
# ╚══════════════════════════════════════════════════════╝

# ── LS / EZA ─────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --git --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias t3='eza --tree --icons --level=3'
alias la='eza -a --icons'

# ── NAVIGATION ───────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd $HOME'
alias dl='cd /storage/emulated/0/Download'

# ── GENERAL ──────────────────────────────────────────────
alias c='clear'
alias q='exit'
alias nano='nano -l'
alias nn='nano'
alias nz='nano ~/.zshrc'
alias cll='clear && pwd && ll'

# ── TOOLS ────────────────────────────────────────────────
alias cat='bat --paging=never'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -sh'
alias top='htop'
alias find='fd'
alias search='rg'
alias size='ncdu'
alias py='python'
alias pip='pip3'

# ── NOTE ─────────────────────────────────────────────────
alias n='bash $NOTE_SH'
alias nd='bash $NOTE_SH daily'

# ── KOS ──────────────────────────────────────────────────
alias kc='kos capture'
alias ks='kos status'
alias kd='kos daily'
alias kf='kos search'

# ── VAULT ────────────────────────────────────────────────
alias upmv='mv /storage/emulated/0/Download/CLAUDE.md $VAULT/system/CLAUDE.md && echo "✓ CLAUDE.md → vault" || echo "✗ failed"'
alias upcp='cp /storage/emulated/0/Download/CLAUDE.md $VAULT/system/CLAUDE.md && echo "✓ CLAUDE.md → vault" || echo "✗ failed"'

# ── CLI TOOLS ────────────────────────────────────────────
alias bugscan='bash $HOME/projects/bugscan/bugscan.sh'
alias ussdth='python $HOME/projects/tools/ussdth.py'

# bugscan shortcuts
alias bs='bugscan . -s node_modules'
alias bsd='bugscan . -s node_modules -d'
alias bso='bugscan . -s node_modules -o'
alias bsdiff='bugscan --diff'

alias vsave='cd $VAULT && git add system/CLAUDE.md && git commit -m "claude update $(date +%Y-%m-%d)" && cd -'
