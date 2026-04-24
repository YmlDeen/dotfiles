#!/bin/bash
# restore.sh — Termux Disaster Recovery
# repo: YmlDeen/dotfiles
# run: bash restore.sh
# เวลา: ~10 นาที | Termux ใหม่/reset → กลับมาใช้ได้เลย

set -euo pipefail

# ─── COLORS ────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }
step() { echo -e "\n${BOLD}[$1]${NC} $2"; }

# ─── PATHS ─────────────────────────────────────────────────────
HOME_DIR="/data/data/com.termux/files/home"
PROJECTS="$HOME_DIR/projects"
DL="/storage/emulated/0/Download"
VAULT_SRC="$DL/vault"
VAULT_LINK="$PROJECTS/vault"
ZSH_CFG="$HOME_DIR/.config/zsh"
DOTFILES="$PROJECTS/dotfiles"

echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     Termux Restore — YmlDeen         ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"

# ─── 0. PRE-CHECK ──────────────────────────────────────────────
step "0/6" "Pre-check"

if [ ! -d "$DL" ]; then
  fail "ไม่เจอ /storage — รัน: termux-setup-storage แล้วรีสตาร์ท Termux ก่อน"
  exit 1
fi
ok "storage พร้อม"

mkdir -p "$PROJECTS"
mkdir -p "$HOME_DIR/.config"
mkdir -p "$HOME_DIR/tmp"
ok "directories พร้อม"

# ─── 1. PACKAGES ───────────────────────────────────────────────
step "1/6" "Installing packages"

info "pkg update..."
pkg update -y 2>/dev/null || true
pkg upgrade -y 2>/dev/null || true

PACKAGES=(
  # shell
  zsh zsh-completions bash coreutils
  # network
  curl wget openssh
  # git
  git git-delta git-lfs lazygit gh
  # modern tools
  eza bat fzf fd ripgrep zoxide
  # terminal
  tmux nano neovim bc
  # dev
  nodejs npm python python-pip
  # utils
  jq tree ncdu htop unzip tar dos2unix patch
  # termux
  termux-api termux-tools
)

FAILED_PKGS=()
for pkg in "${PACKAGES[@]}"; do
  if pkg install -y "$pkg" 2>/dev/null; then
    ok "$pkg"
  else
    fail "$pkg (skip)"
    FAILED_PKGS+=("$pkg")
  fi
done

if [ ${#FAILED_PKGS[@]} -gt 0 ]; then
  echo -e "\n  ${YELLOW}⚠ packages ที่ install ไม่ได้: ${FAILED_PKGS[*]}${NC}"
fi

# ─── 2. GH AUTH + CLONE ────────────────────────────────────────
step "2/6" "GitHub auth + clone repos"

if ! gh auth status 2>/dev/null | grep -q "Logged in"; then
  echo ""
  info "ต้อง login GitHub ก่อน — จะเปิด browser auth:"
  gh auth login --web --hostname github.com --scopes "repo,read:org"
else
  ok "gh auth — logged in แล้ว"
fi

REPOS=(
  dotfiles
  linkbox
  bugscan
  sysreport
  tools
  promptkit
)
# brun — ไม่มี .git ข้าม

CLONE_FAILED=()
for repo in "${REPOS[@]}"; do
  TARGET="$PROJECTS/$repo"
  if [ -d "$TARGET/.git" ]; then
    info "$repo — มีอยู่แล้ว (pull)"
    git -C "$TARGET" pull --ff-only 2>/dev/null && ok "$repo updated" || fail "$repo pull failed"
  else
    if gh repo clone "YmlDeen/$repo" "$TARGET" 2>/dev/null; then
      ok "$repo cloned"
    else
      fail "$repo clone failed"
      CLONE_FAILED+=("$repo")
    fi
  fi
done

if [ ${#CLONE_FAILED[@]} -gt 0 ]; then
  echo -e "\n  ${YELLOW}⚠ repos ที่ clone ไม่ได้: ${CLONE_FAILED[*]}${NC}"
fi

# ─── 3. DOTFILES — SYMLINKS ────────────────────────────────────
step "3/6" "Dotfiles + zsh config"

if [ ! -d "$DOTFILES/zsh" ]; then
  fail "ไม่เจอ $DOTFILES/zsh — clone dotfiles ก่อน (step 2 พัง?)"
else
  # สร้าง ~/.config/zsh → ~/projects/dotfiles/zsh/
  if [ -L "$ZSH_CFG" ]; then
    rm "$ZSH_CFG"
  elif [ -d "$ZSH_CFG" ]; then
    mv "$ZSH_CFG" "${ZSH_CFG}.bak.$(date +%s)"
    info "backup เก่าไว้ที่ ${ZSH_CFG}.bak.*"
  fi

  ln -sf "$DOTFILES/zsh" "$ZSH_CFG"
  ok "~/.config/zsh → $DOTFILES/zsh"

  # เปลี่ยน shell เป็น zsh
  if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s zsh 2>/dev/null && ok "default shell → zsh" || info "chsh ไม่ได้ — เปิด zsh เองได้"
  else
    ok "default shell = zsh แล้ว"
  fi
fi

# ─── 4. SYMLINKS + EXPORTS ─────────────────────────────────────
step "4/6" "Symlinks + vault"

# vault symlink: ~/projects/vault → $DL/vault
if [ -d "$VAULT_SRC" ]; then
  if [ -L "$VAULT_LINK" ]; then
    rm "$VAULT_LINK"
  elif [ -d "$VAULT_LINK" ]; then
    mv "$VAULT_LINK" "${VAULT_LINK}.bak.$(date +%s)"
  fi
  ln -sf "$VAULT_SRC" "$VAULT_LINK"
  ok "vault symlink: ~/projects/vault → $DL/vault"
else
  fail "ไม่เจอ $VAULT_SRC — vault ยังไม่มีใน Download"
  info "สร้างได้เองทีหลัง: ln -sf $DL/vault $VAULT_LINK"
fi

# ─── 5. NPM INSTALL ────────────────────────────────────────────
step "5/6" "npm install"

NPM_PROJECTS=(linkbox tools promptkit)

for proj in "${NPM_PROJECTS[@]}"; do
  DIR="$PROJECTS/$proj"
  if [ -f "$DIR/package.json" ]; then
    info "npm install — $proj"
    if npm install --prefix "$DIR" 2>/dev/null; then
      ok "$proj"
    else
      fail "$proj npm install failed"
    fi
  else
    fail "$proj — ไม่เจอ package.json (clone พัง?)"
  fi
done

# ─── 6. VERIFY ─────────────────────────────────────────────────
step "6/6" "Verify"

echo ""
echo -e "${BOLD}PROJECT STATUS:${NC}"
printf "  %-12s %-10s %-10s\n" "PROJECT" "GIT" "NODE_MOD"
printf "  %-12s %-10s %-10s\n" "───────" "───" "────────"

ALL_PROJECTS=(linkbox bugscan sysreport tools dotfiles vault promptkit)

for proj in "${ALL_PROJECTS[@]}"; do
  DIR="$PROJECTS/$proj"
  git_status="—"
  nm_status="—"

  if [ -d "$DIR/.git" ]; then
    git_status="${GREEN}✓${NC}"
  elif [ -L "$DIR" ]; then
    git_status="${CYAN}link${NC}"
  else
    git_status="${RED}✗${NC}"
  fi

  if [ -d "$DIR/node_modules" ]; then
    nm_status="${GREEN}✓${NC}"
  elif [ -f "$DIR/package.json" ]; then
    nm_status="${RED}✗${NC}"
  fi

  printf "  %-12s " "$proj"
  echo -e "${git_status}         ${nm_status}"
done

echo ""

# forge status (ถ้ามี)
if command -v forge &>/dev/null; then
  info "forge status:"
  forge status 2>/dev/null || true
elif [ -f "$PROJECTS/tools/forge.js" ]; then
  info "forge status:"
  node "$PROJECTS/tools/forge.js" status 2>/dev/null || true
fi

echo ""
echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     Restore Complete ✓               ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Manual steps:${NC}"
echo "  1. เปิด Termux ใหม่ (โหลด zsh config)"
echo "  2. zsh (ถ้ายัง bash อยู่)"
echo "  3. source \$ZSH_CFG/exports.zsh"
echo ""
