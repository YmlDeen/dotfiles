#!/bin/bash
# restore.sh — Termux Environment Restore
# repo: YmlDeen/dotfiles
# run: bash restore.sh

set -e

OK="✓"
FAIL="✗"

echo "=== Termux Restore Start ==="
echo ""

# ─── 1. PACKAGES ───────────────────────────────────────────
echo "[1/4] Installing packages..."

pkg update -y 2>/dev/null

PACKAGES=(
  # core
  apt bash zsh zsh-completions coreutils curl wget git openssh
  # tools
  eza bat fzf fd ripgrep zoxide tmux lazygit gh
  lsof jq tree ncdu htop nano sd entr dos2unix patch unzip tar
  # editors
  neovim lua51 lua54 luajit tree-sitter
  tree-sitter-bash tree-sitter-c tree-sitter-css
  tree-sitter-html tree-sitter-javascript tree-sitter-json
  tree-sitter-lua tree-sitter-markdown tree-sitter-python
  tree-sitter-rust tree-sitter-yaml tree-sitter-vim
  tree-sitter-vimdoc tree-sitter-query tree-sitter-regex
  tree-sitter-toml tree-sitter-xml tree-sitter-go
  tree-sitter-java tree-sitter-sql tree-sitter-latex
  tree-sitter-parsers
  # languages
  python python-pip python-numpy nodejs npm rust clang cmake make
  # dev
  shellcheck git-delta git-lfs
  # termux
  termux-api termux-am termux-tools termux-core
  # misc
  ranger nmap proot proot-distro
)

for pkg in "${PACKAGES[@]}"; do
  if pkg install -y "$pkg" 2>/dev/null; then
    echo "  $OK $pkg"
  else
    echo "  $FAIL $pkg (skip)"
  fi
done

echo ""

# ─── 2. DOTFILES ───────────────────────────────────────────
echo "[2/4] Restoring dotfiles..."

if git clone https://github.com/YmlDeen/dotfiles ~/dotfiles 2>/dev/null; then
  cp ~/dotfiles/.zshrc ~/.zshrc
  echo "  $OK .zshrc restored"
else
  echo "  $FAIL dotfiles clone failed — check SSH/token"
fi

echo ""

# ─── 3. PROJECTS ───────────────────────────────────────────
echo "[3/4] Cloning projects..."

mkdir -p ~/projects

REPOS=(
  kos
  dex
  axl
  linkbox
  sysreport
  bugscan
  tools
)

for repo in "${REPOS[@]}"; do
  if git clone https://github.com/YmlDeen/$repo ~/projects/$repo 2>/dev/null; then
    echo "  $OK $repo"
  else
    echo "  $FAIL $repo (skip)"
  fi
done

# KOS อยู่ที่ ~/kos ไม่ใช่ ~/projects/kos
mv ~/projects/kos ~/kos 2>/dev/null && echo "  $OK kos moved to ~/kos" || true

echo ""

# ─── 4. MANUAL STEPS ───────────────────────────────────────
echo "[4/4] Done. Manual steps remaining:"
echo ""
echo "  [ ] source ~/.zshrc"
echo "  [ ] gh auth login"
echo "  [ ] npm install in: dex / axl / linkbox"
echo "  [ ] pip install bandit"
echo "  [ ] restore vault from /storage/emulated/0/Download/vault/"
echo "  [ ] setup neovim plugins (open nvim)"
echo ""
echo "=== Restore Complete ==="
