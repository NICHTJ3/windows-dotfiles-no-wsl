set EDITOR=nvim

rem Copy files
robocopy *.vim C:\Users\TrentNicholson\AppData\Local\nvim .

rem Add and commit
git add .
git commit -v

git push
