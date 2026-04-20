# ╔══════════════════════════════════════════════════════╗
# ║  prompt.zsh — prompt + header + safety zone          ║
# ║  version: 3.4 | 2026-04-19                           ║
# ╚══════════════════════════════════════════════════════╝

# ── SAFETY ZONE ──────────────────────────────────────────
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
_ix_status() {
  if [[ $? -eq 0 ]]; then echo "%F{green}✓%f"
  else echo "%F{red}✗%f"
  fi
}
PROMPT='
%F{cyan}┌[%f%F{yellow}%/%f%F{cyan}]%f $(_ix_status)
$(_ix_zone_arrow) '

# ── BAR BUILDER ──────────────────────────────────────────
_ix_bar() {
  local used=$1 total=$2 width=12
  local pct filled empty bar color
  (( total == 0 )) && total=1
  pct=$(( used * 100 / total ))
  filled=$(( pct * width / 100 ))
  empty=$(( width - filled ))
  if   (( pct < 60 )); then color="\033[0;32m"
  elif (( pct < 80 )); then color="\033[1;33m"
  else                      color="\033[0;31m"
  fi
  bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty;  i++)); do bar+="░"; done
  printf "${color}%s\033[0m" "$bar"
}

# ── RAM ──────────────────────────────────────────────────
_ix_ram() {
  local total_kb free_kb used_kb used_int total_int used_g total_g bar
  total_kb=$(grep MemTotal     /proc/meminfo | awk '{print $2}')
  free_kb=$(grep  MemAvailable /proc/meminfo | awk '{print $2}')
  used_kb=$(( total_kb - free_kb ))
  used_int=$(( used_kb  / 1048576 ))
  total_int=$(( total_kb / 1048576 ))
  used_g=$(echo "scale=1; $used_kb/1048576"  | bc)
  total_g=$(echo "scale=1; $total_kb/1048576" | bc)
  bar=$(_ix_bar $used_int $total_int)
  printf "[%b]  \033[1;37m%s\033[0;90m/%s G\033[0m" "$bar" "$used_g" "$total_g"
}

# ── STORAGE ──────────────────────────────────────────────
_ix_sto() {
  local row total_g used_g used_int total_int bar
  row=$(df -h /storage/emulated/0 2>/dev/null | tail -1)
  [[ -z "$row" ]] && { printf "[\033[0;90m────────────\033[0m]  \033[0;90mn/a\033[0m"; return }
  total_g=$(echo "$row" | awk '{gsub(/G/,"",$2); print $2}')
  used_g=$(echo  "$row" | awk '{gsub(/G/,"",$3); print $3}')
  used_int=${used_g%.*}
  total_int=${total_g%.*}
  (( total_int == 0 )) && total_int=1
  bar=$(_ix_bar $used_int $total_int)
  printf "[%b]  \033[1;37m%s\033[0;90m/%s G\033[0m" "$bar" "$used_g" "$total_g"
}

# ── CPU ──────────────────────────────────────────────────
_ix_cpu() {
  local kernel arch
  kernel=$(uname -r | cut -d'-' -f1)
  arch=$(uname -m)
  printf "\033[1;37m%s\033[0m  \033[0;90mkernel %s\033[0m" "$arch" "$kernel"
}

# ── HEADER ───────────────────────────────────────────────
_ix_header() {
  local D="\033[0;90m"   # dim gray
  local G="\033[0;37m"   # gray
  local W="\033[1;37m"   # white
  local C="\033[1;36m"   # cyan
  local R="\033[0m"

  # gradient: dim→gray→white→cyan→white→gray→dim
local title="${D}░▒▓${R} ${D}◀${R}  ${G}i${W}x${C}Termux${R}  ${D}▶${R} ${D}▓▒░${R}"
  local div="${D}  ──────────────────────────────${R}"

  echo ""
  echo -e "  $title"
  echo -e "$div"
  printf  "  ${D}MEM${R}  "; _ix_ram; echo ""
  printf  "  ${D}STO${R}  "; _ix_sto; echo ""
  printf  "  ${D}CPU${R}  "; _ix_cpu; echo ""
  echo -e "$div"
  echo -e "  ${D}»${R}  ${C}n${R} ${D}·${R} ${C}nlog${R} ${D}·${R} ${C}nd${R} ${D}·${R} ${C}j${R} ${D}·${R} ${C}gs${R} ${D}·${R} ${C}scall${R}"
  echo ""
}

_ix_header
