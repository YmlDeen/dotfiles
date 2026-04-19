# ╔══════════════════════════════════════════════════════╗
# ║  projects.zsh — web apps                             ║
# ║  ports: dex=3001  axl=3002  linkbox=3003             ║
# ║  port ใหม่เริ่มที่ 3004+                              ║
# ╚══════════════════════════════════════════════════════╝

alias dex='cd ~/projects/dex && PORT=3001 npm start'
alias axl='cd ~/projects/axl && PORT=3002 npm start'
alias linkbox='cd ~/projects/linkbox && PORT=3003 node server.js'
