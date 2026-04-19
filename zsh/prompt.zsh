# ╔══════════════════════════════════════════════════════╗
# ║  prompt.zsh — prompt + header + safety zone          ║
# ╚══════════════════════════════════════════════════════╝

# ── SAFETY ZONE ──────────────────────────────────────────
# 🔴 /system /proc /dev /etc   (อันตราย)
# 🟠 /storage /sdcard           (ระวัง)
# 🟢 $HOME/**                   (ปลอดภัย)
# ⚪ อื่นๆ                        (กลาง)

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
