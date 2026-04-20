# ╔══════════════════════════════════════════════════════╗
# ║  functions.zsh — all functions                       ║
# ╚══════════════════════════════════════════════════════╝

# ── NAVIGATION ───────────────────────────────────────────
declare -A JUMP_DIRS
JUMP_DIRS[home]="$HOME"
JUMP_DIRS[proj]="$HOME/projects"
JUMP_DIRS[dl]="/storage/emulated/0/Download"
JUMP_DIRS[cfg]="$HOME/.config"
JUMP_DIRS[vault]="$VAULT"
JUMP_DIRS[inbox]="$VAULT/00-inbox"
JUMP_DIRS[tools]="$HOME/projects/tools"
JUMP_DIRS[zsh]="$HOME/.config/zsh"

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
  [[ -z "$1" || -z "$2" ]] && echo "usage: ja <name> <path>" && return
  JUMP_DIRS[$1]="${2}"
  echo "\033[0;32m✓ bookmark: $1 → $2\033[0m"
}

mkcd() {
  [[ -z "$1" ]] && echo "usage: mkcd <dir>" && return
  mkdir -p "$1" && cd "$1" && echo "\033[0;32m✓ created: $PWD\033[0m"
}

up() {
  local n="${1:-1}" path=""
  for ((i=0; i<n; i++)); do path="../$path"; done
  cd "$path" && echo "\033[0;32m➤ $PWD\033[0m"
}

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

# ── CONFIG ───────────────────────────────────────────────
zrc()      { source "$HOME/.zshrc" && echo "\033[0;32m✓ .zshrc reloaded\033[0m"; }
src()      { zrc; }
edit-zrc() { nano -l "$HOME/.zshrc"; source "$HOME/.zshrc" && echo "\033[0;32m✓ saved + reloaded\033[0m"; }

# ── FILE SHARING ─────────────────────────────────────────
# share <file>  → ส่ง file ไป Download/
# share         → fzf เลือกไฟล์ใน $PWD (max-depth 2)
_DL="/storage/emulated/0/Download"
_DL_EXCLUDE=(secrets keys _old archive)

share() {
  local exclude_args=()
  for d in "${_DL_EXCLUDE[@]}"; do exclude_args+=(--exclude "$d"); done

  if [[ -n "$1" ]]; then
    cp "$1" "$_DL/" && echo "\033[0;32m✓ $1 → Download/\033[0m"
  else
    local file
    file=$(fd --type f --max-depth 2 "${exclude_args[@]}" . 2>/dev/null \
      | fzf --prompt="share ➤ " --preview='bat --color=always {}')
    [[ -n "$file" ]] && cp "$file" "$_DL/" && echo "\033[0;32m✓ $(basename $file) → Download/\033[0m"
  fi
}

# bring <file>  → รับ file จาก Download/ มา $PWD
# bring         → fzf เลือกไฟล์ใน Download/ (ซ่อน secrets/keys)
bring() {
  local exclude_args=()
  for d in "${_DL_EXCLUDE[@]}"; do exclude_args+=(--exclude "$d"); done

  if [[ -n "$1" ]]; then
    cp "$_DL/$1" "$PWD/" && echo "\033[0;32m✓ $1 → $PWD/\033[0m"
  else
    local file
    file=$(fd --type f --max-depth 1 "${exclude_args[@]}" . "$_DL" 2>/dev/null \
      | fzf --prompt="bring ➤ " --preview='bat --color=always {}')
    [[ -n "$file" ]] && cp "$file" "$PWD/" && echo "\033[0;32m✓ $(basename $file) → $PWD/\033[0m"
  fi
}

# ── INBOX ────────────────────────────────────────────────
# inbox → fzf เลือก note ใน vault/00-inbox/
inbox() {
  local file
  file=$(fd --type f --extension md . "$KOS_INBOX" 2>/dev/null \
    | fzf --prompt="inbox ➤ " \
          --preview='bat --color=always {}' \
          --preview-window=right:60%:wrap)
  [[ -n "$file" ]] && bat "$file"
}

# ── REP
unalias rep 2>/dev/null ──────────────────────────────────────────────────
# rep → รัน sysreport + copy ไป $DL อัตโนมัติ
rep() {
  bash "$HOME/projects/sysreport/sysreport.sh"
  local latest
  latest=$(ls "$HOME/projects/sysreport/reports/"*.md 2>/dev/null | sort | tail -1)
  if [[ -n "$latest" ]]; then
    cp "$latest" "$_DL/"
    echo "\033[0;32m✓ copied → Download/$(basename $latest)\033[0m"
  fi
}

# ── SCALL ────────────────────────────────────────────────
# scall         → แสดงทุก section
# scall nav     → NAV only
# scall note    → NOTE only
# scall git     → GIT only
# scall web     → PROJECT only
# scall tools   → TOOLS only
# scall config  → CONFIG only

_scall_header() {
  echo ""
  echo "  \033[1;36m╔─────────────────────────────────────────╗\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;33mixTermux\033[0m  shortcuts  \033[0;90mscall [section]\033[0m  \033[1;36m║\033[0m"
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
}

_scall_footer() {
  echo "  \033[1;36m╚─────────────────────────────────────────╝\033[0m"
  echo ""
}

_scall_nav() {
  echo "  \033[1;36m║\033[0m  \033[1;35mNAV\033[0m  — ย้าย folder          \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  j <n>         ไปที่ bookmark           \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  ja <n> <p>    เพิ่ม bookmark ใหม่      \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  fj            fzf เลือก folder         \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  z <n>         zoxide smart jump        \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  up [n]        ขึ้น n ระดับ              \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  mkcd <dir>    สร้าง folder แล้วเข้าเลย \033[1;36m║\033[0m"
}

_scall_note() {
  echo "  \033[1;36m║\033[0m  \033[1;35mNOTE\033[0m  — บันทึก         \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  n \"title\"     จดโน้ตลง inbox           \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  nlog \"msg\"    บันทึกลง dev-log         \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  nd            เปิด daily note วันนี้    \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  kc            บันทึกลง KOS              \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  inbox         fzf เปิด note ใน inbox    \033[1;36m║\033[0m"
}

_scall_web() {
  echo "  \033[1;36m║\033[0m  \033[1;35mWEB\033[0m  — เปิด web app          \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  exl           Smart Notes   :3005      \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  linkbox       Link Manager  :3003      \033[1;36m║\033[0m"
}

_scall_git() {
  echo "  \033[1;36m║\033[0m  \033[1;35mGIT\033[0m  — version control           \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gs            status                   \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  ga .          add all                  \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gc \"msg\"      commit                   \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gp            push                     \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gl            log graph                \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  lg            lazygit UI               \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gsave \"msg\"   add+commit+push          \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  gsaveall      push ทุก repo            \033[1;36m║\033[0m"
}

_scall_tools() {
  echo "  \033[1;36m║\033[0m  \033[1;35mTOOLS\033[0m  — เครื่องมือ        \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  share [file]  ส่งไป Download/ (fzf)    \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  bring [file]  รับจาก Download/ (fzf)   \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  bs            bugscan current dir       \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  rep           system report + copy DL   \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  ff            fzf open file in nvim     \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  size          ncdu disk usage           \033[1;36m║\033[0m"
}

_scall_config() {
  echo "  \033[1;36m║\033[0m  \033[1;35mCONFIG\033[0m  — ตั้งค่า shell         \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  zrc           reload .zshrc             \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  edit-zrc      แก้ .zshrc + reload       \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  upcp          sync CLAUDE.md → vault    \033[1;36m║\033[0m"
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
  echo "  \033[1;36m║\033[0m  \033[1;35mSAFETY\033[0m  — สีลูกศร prompt          \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  \033[0;32m🟢 └─➤\033[0m  ~/  ปลอดภัย          \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  🟠 └─➤  /storage  ระวัง                \033[1;36m║\033[0m"
  echo "  \033[1;36m║\033[0m  \033[0;31m🔴 └─❯\033[0m  /system  อันตราย!          \033[1;36m║\033[0m"
}

_scall_divider() {
  echo "  \033[1;36m╠─────────────────────────────────────────╣\033[0m"
}

scall() {
  local section="${1:-all}"
  _scall_header
  case "$section" in
    nav)    _scall_nav ;;
    note)   _scall_note ;;
    web)    _scall_web ;;
    git)    _scall_git ;;
    tools)  _scall_tools ;;
    config) _scall_config ;;
    all|*)
      _scall_nav;    _scall_divider
      _scall_note;   _scall_divider
      _scall_web;    _scall_divider
      _scall_git;    _scall_divider
      _scall_tools;  _scall_divider
      _scall_config
      ;;
  esac
  _scall_footer
}
