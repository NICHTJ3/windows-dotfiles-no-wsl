set EDITOR=nvim

# Copy nvim init file
cp $env:LOCALAPPDATA\nvim\init.vim .

# Copy profile
cp $PROFILE.CurrentUserAllHosts .

# Add and commit files
git add .
git commit -v

git push
