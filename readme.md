# dotfiles

Various dotfiles for configuring and personalising programs on Windows and Linux.

## Install

### Powershell

``` Powershell
# Normal install
. .\install.ps1 -User "Me", "You"

# Install with Force - overwrites any existing files
. .\install.ps1 -User "Me" -Force

# Install only VS Code
. .\install.ps1 -User "Me" -Include "code"

# Install everything but Vim
. .\install.ps1 -User "Me" -Exclude "vim"
```

## Uninstall

### Powershell

``` Powershell
# Powershell (Windows or Core)
. .\uninstall.ps1 -User "Me", "You"
```