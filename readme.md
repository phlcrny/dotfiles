# dotfiles

Now features low-quality Powershell for quick installation, and lower quality shell scripts for Linux!

## Getting Started

```Powershell
# Install with symlinks for the current user
. .\install.ps1 -InstallSymlinks

# Install with file copies
. .\install.ps1 -InstallCopies

# Install a subset of files
. .\install.ps1 -InstallSymlinks -Include "Visual Studio Code"

# Install with symlinks but exclude that one annoying thing
. .\install.ps1 -InstallSymlinks -Exclude "Vim"

# Uninstall for the current user
. .\uninstall.ps1

# Uninstall a subset of files
. .\uninstall.ps1 -Include "Visual Studio Code"

# Uninstall everything but that special something
. .\uninstall.ps1 -Include "tmux"
```
