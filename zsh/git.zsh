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
  git add . && git commit -m "$msg" && git push && echo "\033[0;32m✓ pushed: $msg\033[0m"
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
    echo "\n\033[1;36m── $(basename $repo) ──\033[0m"
    cd "$repo" && git add . && git commit -m "$msg" && git push \
      && echo "\033[0;32m✓ pushed\033[0m" \
      || echo "\033[0;33m✗ failed/nothing\033[0m"
  done
  cd ~
}
