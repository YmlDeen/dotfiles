#!/bin/bash
BASE="https://github.com/YmlDeen"
repos=(KOS exl linkbox notes bugscan sysreport tools dotfiles)

for r in "${repos[@]}"; do
  dest=~/projects/${r,,}
  if [ -d "$dest" ]; then
    echo "skip $r (exists)"
  else
    git clone "$BASE/$r" "$dest"
  fi
done
