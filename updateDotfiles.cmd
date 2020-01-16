set EDITOR=nvim

rem Copy files
robocopy *.vim C:\Users\TrentNicholson\AppData\Local\nvim .

robocopy *.ps1 C:\Users\TrentNicholson\Documents\WindowsPowerShell .

rem Add and commit
git add .
git commit -v

git push
