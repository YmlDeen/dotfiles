# ╔══════════════════════════════════════════════════════╗
# ║  git.zsh — git aliases & workflows                   ║
# ╚══════════════════════════════════════════════════════╝

alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -15'
alias lg='lazygit'

gsave() {
  local msg="${1:-update}"
  git add . && git commit -m "$msg" && git pull --rebase origin main && git push && echo "\033[0;32m✓ pushed: $msg\033[0m"
}

gsaveall() {
  local msg="${1:-update}"
  local repos=(
    ~/projects/linkbox
    ~/projects/bugscan
    ~/projects/sysreport
    ~/projects/tools
    ~/projects/dotfiles
    ~/projects/vault
    ~/projects/promptkit
    ~/projects/trak
    ~/projects/nexus
  )
  local pushed=() skipped=() failed=()

  for repo in "${repos[@]}"; do
    local name=$(basename $repo)
    if [[ ! -d "$repo/.git" ]]; then
      skipped+=("$name")
      continue
    fi
    echo "\n\033[1;36m── $name ──\033[0m"
    cd "$repo"
    if [[ -z "$(git status --porcelain)" ]]; then
      echo "\033[0;90m  nothing to commit\033[0m"
      skipped+=("$name")
    else
      git add . && git commit -m "$msg" && git pull --rebase origin main && git push \
        && pushed+=("$name") \
        || failed+=("$name")
    fi
  done

  cd ~
  echo "\n\033[1;36m── SUMMARY ─────────────────────────\033[0m"
  [[ ${#pushed[@]}  -gt 0 ]] && echo "\033[0;32m  ✓ pushed  : ${pushed[*]}\033[0m"
  [[ ${#skipped[@]} -gt 0 ]] && echo "\033[0;90m  – clean   : ${skipped[*]}\033[0m"
  [[ ${#failed[@]}  -gt 0 ]] && echo "\033[0;31m  ✗ failed  : ${failed[*]}\033[0m"
}
