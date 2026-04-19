# dotfiles

Backup + restore สำหรับ Termux environment
ใช้เมื่อเครื่องพัง เปลี่ยนเครื่อง หรือ fresh install

## Structure

```
dotfiles/
├── restore.sh     ← รันอันเดียวจบ
├── .zshrc         ← backup ของ ~/.zshrc
└── README.md
```

## Restore — เครื่องใหม่/พัง

```bash
pkg install git
git clone https://github.com/YmlDeen/dotfiles ~/dotfiles
bash ~/dotfiles/restore.sh
```

### restore.sh ทำอะไร

```
1/4  ติดตั้ง packages ทั้งหมด (pkg + pip + npm)
2/4  clone dotfiles + restore .zshrc
3/4  clone projects ทั้งหมด:
     kos → ~/kos/
     dex / axl / linkbox / sysreport / bugscan / tools → ~/projects/
4/4  แสดง manual steps ที่เหลือ
```

### Manual steps หลัง restore

```bash
source ~/.zshrc
gh auth login
cd ~/projects/dex && npm install
cd ~/projects/axl && npm install
cd ~/projects/linkbox && npm install
pip install bandit --break-system-packages
# restore vault จาก /storage/emulated/0/Download/vault/
# setup neovim plugins (เปิด nvim)
```

## Update — หลังแก้ zsh config

```bash
cp ~/.zshrc ~/dotfiles/.zshrc
cd ~/dotfiles && gsave "update .zshrc"
```

## Repos ที่ restore ครอบคลุม

| repo | path |
|------|------|
| dotfiles | ~/dotfiles/ |
| kos | ~/kos/ |
| dex | ~/projects/dex/ |
| axl | ~/projects/axl/ |
| linkbox | ~/projects/linkbox/ |
| sysreport | ~/projects/sysreport/ |
| bugscan | ~/projects/bugscan/ |
| tools | ~/projects/tools/ |
