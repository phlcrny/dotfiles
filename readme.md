# dotfiles

Various dotfiles for configuring and personalising programs on Windows and Linux.

Now featuring low-quality shell scripting!

## Install

``` Powershell
# Normal install
. .\install.ps1 -User "Me", "You"

# Install with Force - overwrites any existing files
. .\install.ps1 -User "Me" -Force

# Install only VS Code
. .\install.ps1 -User "Me" -Include "code"

# Install everything but Vim
. .\install.ps1 -User "Me" -Exclude "vim"

# Install only the VS Code extensions for the current user
. .\install.ps1 -InstallVSCodeExtensions -SkipSymlinks
```

``` Bash
# Installs sym-links for the current user, assuming that the files are in ~/dotfiles - this is even worse than the Powershell!
.\install.sh
```

## Uninstall

``` Powershell
# Powershell (Windows or Core)
. .\uninstall.ps1 -User "Me", "You"
```
