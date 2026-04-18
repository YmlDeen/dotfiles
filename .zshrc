# ╔══════════════════════════════════════════════════════╗
# ║           ixTermux — .zshrc                          ║
# ║         zsh config  •  reload: zrc                   ║
# ║         version: 2.3 | 2026-04-19                    ║
# ╚══════════════════════════════════════════════════════╝
# CHANGES v2.3:
#   + dex2 → dex (port 3001)
#   + webtools → linkbox (port 3003)
#   + ลบ USSDTH aliases (uapps, ulabs, ucore, uscripts, ssa, devagent, agentC)
#   + gsaveall อัปเดต repos ใหม่ (linkbox, tools)
#   + ลบ USSDTH จาก gsaveall

# ── PATH ────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── ENV ──────────────────────────────────────────────────
export VAULT="/storage/emulated/0/Download/vault"
export NOTE_VAULT="$VAULT"
export NOTE_SH="$HOME/note.sh"
export KOS_ROOT="$HOME/kos"
export KOS_VAULT="$VAULT"
export KOS_INBOX="$VAULT/00-inbox"
export PATH="$KOS_ROOT:$PATH"

# ── HISTORY ──────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE

# ── COMPLETION ───────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ════════════════════════════════════════════════════════
#  SAFETY ZONE — prompt color by path
#  🔴 /system /proc /dev /etc   (อันตราย)
#  🟠 /storage /sdcard           (ระวัง)
#  🟢 $HOME/**                   (ปลอดภัย)
#  ⚪ อื่นๆ                        (กลาง)
# ════════════════════════════════════════════════════════
_ix_zone_arrow() {
  local p="$PWD"
  if [[ "$p" == /system* || "$p" == /proc* || "$p" == /dev* || "$p" == /etc* ]]; then
    echo "%F{red}└─❯%f"
  elif [[ "$p" == /storage* || "$p" == /sdcard* ]]; then
    echo "%F{214}└─➤%f"
  elif [[ "$p" == $HOME* ]]; then
    echo "%F{green}└─➤%f"
  else
    echo "%F{white}└─➤%f"
  fi
}

setopt PROMPT_SUBST

PROMPT='
%F{cyan}┌[%f%F{yellow}%/%f%F{cyan}]%f
$(_ix_zone_arrow) '

# ── HEADER ───────────────────────────────────────────────
_ix_header() {
  echo ""
  echo " \033[1;36m╔══════════════════════════════════╗\033[0m"
  echo " \033[1;36m║\033[0m  \033[1;33mix\033[1;37mTermux\033[0m  \033[0;90m•  ui/ux shell\033[0m        \033[1;36m║\033[0m"
  echo " \033[1;36m║\033[0m  \033[0;32m$(date '+%a %d %b %Y  %H:%M')\033[0m         \033[1;36m║\033[0m"
  echo " \033[1;36m╚══════════════════════════════════╝\033[0m"
  echo "  \033[0;90mtype \033[0;36mscall\033[0;90m  for shortcuts\033[0m"
  echo ""
}
_ix_header

# ════════════════════════════════════════════════════════
#  JUMP SYSTEM — dir bookmarks
# ════════════════════════════════════════════════════════
declare -A JUMP_DIRS
JUMP_DIRS[home]="$HOME"
JUMP_DIRS[proj]="$HOME/projects"
JUMP_DIRS[dl]="/storage/emulated/0/Download"
JUMP_DIRS[cfg]="$HOME/.config"
JUMP_DIRS[vault]="$VAULT"
JUMP_DIRS[inbox]="$VAULT/00-inbox"
JUMP_DIRS[tools]="$HOME/projects/tools"

j() {
  if [[ -z "$1" ]]; then
    echo "\033[1;36m── Jump Bookmarks ─────────────────\033[0m"
    for k in "${(@k)JUMP_DIRS}"; do
      printf "  \033[1;33m%-8s\033[0m → \033[0;37m%s\033[0m\n" "$k" "${JUMP_DIRS[$k]}"
    done
    return
  fi
  local target="${JUMP_DIRS[$1]}"
  if [[ -n "$target" ]]; then
    cd "$target" && echo "\033[0;32m➤ $target\033[0m"
  else
    local found
    found=$(fd -t d -d 4 "$1" "$HOME" 2>/dev/null | head -1)
    if [[ -n "$found" ]]; then
      cd "$found" && echo "\033[0;32m➤ $found\033[0m"
    else
      echo "\033[0;31m✗ ไม่พบ: $1\033[0m"
    fi
  fi
}

ja() {
  [[ -z "$1" || -z "$2" ]] && echo "usage: ja <n> <path>" && return
  JUMP_DIRS[$1]="${2}"
  echo "\033[0;32m✓ เพิ่ม bookmark: $1 → $2\033[0m"
}

# ════════════════════════════════════════════════════════
#  UTILITY FUNCTIONS
# ════════════════════════════════════════════════════════

mkcd() {
  [[ -z "$1" ]] && echo "usage: mkcd <dir>" && return
  mkdir -p "$1" && cd "$1" && echo "\033[0;32m✓ created + entered: $PWD\033[0m"
}

up() {
  local n="${1:-1}"
  local path=""
  for ((i=0; i<n; i++)); do path="../$path"; done
  cd "$path" && echo "\033[0;32m➤ $PWD\033[0m"
}

zrc()      { source "$HOME/.zshrc" && echo "\033[0;32m✓ .zshrc reloaded\033[0m"; }
src()      { zrc; }
edit-zrc() { nano -l "$HOME/.zshrc"; source "$HOME/.zshrc" && echo "\033[0;32m✓ saved + reloaded\033[0m"; }

fj() {
  local dir
  dir=$(fd -t d -d 5 . "$HOME" 2>/dev/null | fzf --prompt="jump ➤ ")
  [[ -n "$dir" ]] && cd "$dir" && echo "\033[0;32m➤ $PWD\033[0m"
}

ff() {
  local file
  file=$(fd --type f 2>/dev/null | fzf --prompt="open ➤ " --preview='bat --color=always {}')
  [[ -n "$file" ]] && nvim "$file"
}

# ════════════════════════════════════════════════════════
#  ALIASES — LS / EZA
# ════════════════════════════════════════════════════════
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

# ── GIT ──────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'        # ดู status สั้น
alias ga='git add'               # add ไฟล์
alias gc='git commit -m'         # commit
alias gp='git push'              # push
alias gl='git log --oneline --graph --decorate -15'  # ดู log
alias lg='lazygit'               # git UI

# ── NOTE (note.sh v2) ────────────────────────────────────
alias n='bash $NOTE_SH'
alias nlog='bash $NOTE_SH log'
alias nd='bash $NOTE_SH daily'

# ── KOS ──────────────────────────────────────────────────
alias kc='kos capture'
alias ks='kos status'
alias kd='kos daily'
alias kf='kos search'

# ════════════════════════════════════════════════════════
#  PROJECTS — web apps
#  ports: dex=3001  axl=3002  linkbox=3003
#  port ใหม่เริ่มที่ 3004+
# ════════════════════════════════════════════════════════
alias dex='cd ~/projects/dex && PORT=3001 npm start'
alias axl='cd ~/projects/axl && PORT=3002 npm start'
alias linkbox='cd ~/projects/linkbox && PORT=3003 node server.js'

# ════════════════════════════════════════════════════════
#  TOOLS — CLI
# ════════════════════════════════════════════════════════
alias rep='bash $HOME/projects/sysreport/sysreport.sh'
alias bugscan='bash $HOME/projects/bugscan/bugscan.sh'
alias ussdth='python $HOME/projects/tools/ussdth.py'

# ── VAULT UTILS ──────────────────────────────────────────
alias upc='mv /storage/emulated/0/Download/CLAUDE.md $VAULT/system/CLAUDE.md'

# ════════════════════════════════════════════════════════
#  GIT WORKFLOW
# ════════════════════════════════════════════════════════

# push repo ปัจจุบัน ในครั้งเดียว
gsave() {
  local msg="${1:-update}"
  git add . && git commit -m "$msg" && git push && echo "✓ pushed: $msg"
}

gsaveall() {
  local msg="${1:-update}"
  local repos=(
    ~/kos
    ~/projects/bugscan
    ~/projects/dex
    ~/projects/axl
    ~/projects/linkbox
    ~/projects/sysreport
    ~/projects/tools
  )
  for repo in "${repos[@]}"; do
    echo "\n── $(basename $repo) ──"
    cd "$repo" && git add . && git commit -m "$msg" && git push && echo "✓ pushed" || echo "✗ failed/nothing"
  done
  cd ~
}

# File sharing
share() { cp "$1" /storage/emulated/0/Download/ && echo "✓ $1 → Download/" }
bring() { cp /storage/emulated/0/Download/"$1" "$PWD/" && echo "✓ $1 → $PWD/" }




# ════════════════════════════════════════════════════════
#  ZOXIDE + PLUGINS
# ════════════════════════════════════════════════════════
eval "$(zoxide init zsh)"
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# ════════════════════════════════════════════════════════
#  SCALL — shortcut all
# ════════════════════════════════════════════════════════
scall() {
  echo ""
  echo "  \033[1;36m╔─────────────────────────────────────────╗\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;33mixTermux\033[0m  shortcut all (scall)     \033[1;36m║\033[0m"
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;35mNAV\033[0m  — ย้าย folder                   \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  j <n>         ไปที่ bookmark           \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  ja <n> <p>    เพิ่ม bookmark ใหม่      \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  fj            เลือก folder ด้วย fzf    \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  z <n>         กระโดดไป dir ที่เคยไป    \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  up [n]        ขึ้น n ระดับ              \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  mkcd <dir>    สร้าง folder แล้วเข้าเลย \033[1;36m║\033[0m"
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;35mNOTE\033[0m  — บันทึก                       \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  n \"title\"     จดโน้ตลง inbox           \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  nlog \"msg\"    บันทึกลง dev-log         \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  nd            เปิด daily note วันนี้    \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  kc            บันทึกลง KOS              \033[1;36m║\033[0m"
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;35mPROJECT\033[0m  — เปิด web app              \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  dex           เปิด dex      :3001       \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  axl           เปิด axl      :3002       \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  linkbox       เปิด linkbox  :3003       \033[1;36m║\033[0m"
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;35mGIT\033[0m  — version control               \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gs            ดู status                 \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  ga .          เพิ่มทุกไฟล์              \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gc \"msg\"      commit                   \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gp            push ขึ้น GitHub           \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gl            ดู log แบบ graph          \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  lg            เปิด lazygit (UI)         \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gsave \"msg\"   add+commit+push ครั้งเดียว\033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gsaveall      push ทุก repo พร้อมกัน    \033[1;36m║\033[0m"
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;35mTOOLS\033[0m  — เครื่องมือ                  \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  bugscan <p>   หาบัคในโค้ด               \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  rep           ดูรายงานระบบ              \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  ussdth        รหัสลัดมือถือไทย          \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  ff            เปิดไฟล์ด้วย fzf+nvim     \033[1;36m║\033[0m"
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;35mCONFIG\033[0m  — ตั้งค่า shell               \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  zrc           reload .zshrc             \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  edit-zrc      แก้ .zshrc แล้ว reload    \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  upc           sync CLAUDE.md → vault    \033[1;36m║\033[0m"
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;35mSAFETY\033[0m  — สีลูกศร prompt              \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  \033[0;32m🟢 └─➤\033[0m  ~/  ปลอดภัย                  \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  🟠 └─➤  /storage  ระวัง                \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  \033[0;31m🔴 └─❯\033[0m  /system  อันตราย!            \033[1;36m║\033[0m"
  echo "  \033[1;36m╚─────────────────────────────────────────╝\033[0m"
  echo ""
}

