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

# ── VAULT ────────────────────────────────────────────────
alias upmv='mv /storage/emulated/0/Download/CLAUDE.md $VAULT/system/CLAUDE.md && echo "✓ CLAUDE.md → vault" || echo "✗ failed"'
alias upcp='cp /storage/emulated/0/Download/CLAUDE.md $VAULT/system/CLAUDE.md && echo "✓ CLAUDE.md → vault" || echo "✗ failed"'
# vsave moved to line 75 — vault-sync

# ── CLI TOOLS ────────────────────────────────────────────
alias bugscan='bash $HOME/projects/bugscan/bugscan.sh'
alias ussdth='python $HOME/projects/tools/ussdth.py'
alias hc='bash ~/projects/tools/hcheck.sh'

# bugscan shortcuts
alias bs='bugscan . -s node_modules'
alias bsd='bugscan . -s node_modules -d'
alias bso='bugscan . -s node_modules -o'
alias bsdiff='bugscan --diff'

# ── ECOSYSTEM ─────────────────────────────────────────────
alias health='bash ~/projects/tools/health.sh'
alias forge='node ~/projects/tools/forge/index.js'
alias pk='pk'

# scanxl
alias scanxl='node ~/projects/scanxl/cli.js'

# Ecosystem SaaS
alias ecosystem='cd /data/data/com.termux/files/home/projects/ecosystem && bash start.sh'

# ctx
alias ctxs='ctx . --sig --stat'
alias ctxp='ctx . --strip --stat'
alias ctxo='ctx . --strip --out /storage/emulated/0/Download/ctx_out.txt && echo "[ctx] done → Download/ctx_out.txt"'

alias clu='nx sync-claude && upcp && vsave && git -C ~/projects/vault push'

alias cls='nx snap && ctx ~/projects/nexus --strip --sig --stat > ~/projects/nexus/tmp/ctx_nexus.txt && share ~/projects/nexus/tmp/ctx_nexus.txt && echo "แนบ CLAUDE.md + snap + ctx_nexus.txt"'

alias vsave='cd $VAULT && git add -A && git commit -m "vault: save" && git push && ~/projects/vault-sync/vsync.sh'

alias imp='node ~/projects/tools/imgprompt.mjs'
alias vps='ssh -i ~/.ssh/id_ed25519 ubuntu@54.179.174.46'
alias hm='hermes'
alias hg='hermes gateway'
