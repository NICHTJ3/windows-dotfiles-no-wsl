Clear-Host
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
cinst chocolatey -y
cinst chocolatey-core.extension -y
cinst chocolatey-dotnetfx.extension -y
cinst chocolatey-visualstudio.extension -y
cinst chocolatey-windowsupdate.extension -y
cinst fzf -y
cinst git -y
cinst neovim -y
cinst PowerShell -y
cinst python -y
Clear-Host
echo "All done!"
Pause
