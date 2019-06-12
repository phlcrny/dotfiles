<#
.SYNOPSIS
    Installs the dotfiles with symbolic links to the relevant locations.
.DESCRIPTION
    Uses the 'New-Item' cmdlet to create symbolic links between individual dotfiles and their expected 'real' locations.
.PARAMETER User
    The user or users who will have the dotfiles installed in their directories. This defaults to the current user.
.PARAMETER Exclude
    Any symlinks whose descriptions match this string will not be installed. Uses regular expression.
.EXAMPLE
    . .\install.ps1 -User "Me", "You"

    Installs the dotfiles for users 'Me' and 'You'.
.EXAMPLE
    . .\install.ps1 -User "Me" -Exclude "vim"

    Installs all available dotfiles for 'Me' except those named 'vim'.
.EXAMPLE
    . .\install.ps1 -User "Me" -Include "vim"

    Only installs dotfiles that match 'vim' for 'Me'.
.INPUTS
    Strings (optional)
.OUTPUTS
    N/A
.NOTES
    Version 1.1.0

    #requires -RunAsAdministrator
    It shouldn't require admin rights, but New-Item seems to be awkward about sym-links.

    Note: This install script is not tested with macOS.
.LINK
    https://github.com/philccarney/dotfiles
#>
[CmdletBinding(ConfirmImpact = 'Low', SupportsShouldProcess = $True, DefaultParameterSetName = "Default")] # Bit rusty with parameter sets, but this seems to work.
param
(
    [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The user(s) the dotfiles will be installed for. Defaults to the current user.")]
    [string[]] $User,

    [Parameter(Mandatory = $False, HelpMessage = "Only symlinks whose descriptions match this string will be installed. Uses regular expression.", ParameterSetName = "Inclusion")]
    [string] $Include,

    [Parameter(Mandatory = $False, HelpMessage = "Any symlinks whose descriptions match this string will not be installed. Uses regular expression.", ParameterSetName = "Exclusion")]
    [string] $Exclude,

    [Parameter(Mandatory = $False, HelpMessage = "Skips the installation of any symlinks", ParameterSetName = "vscodeExtensions")]
    [switch] $SkipSymlinks,

    [Parameter(Mandatory = $False, HelpMessage = "Installs the vscode extensions for the current user.", ParameterSetName = "vscodeExtensions")]
    [switch] $InstallVSCodeExtensions,

    [Parameter(Mandatory = $False, HelpMessage = "Allows any existing symlinks/files to be overwritten.")]
    [switch] $Force
)

BEGIN
{
    if ($PSBoundParameters.ContainsKey("Debug"))
    {
        $DebugPreference = "Continue"
    }
    Write-Debug -Message "BEGIN Block"

    Write-Debug -Message "Determining 'User' parameter."
    if ($PSBoundParameters.ContainsKey("User"))
    {
        [string[]] $Users = $PSBoundParameters.User
    }
    else
    {
        [string[]] $Users = [System.Environment]::UserName
    }
    if ($PSBoundParameters.ContainsKey("Exclude"))
    {
        [string] $Exclude = $Exclude
    }

    Write-Debug -Message "Determining 'OS' version."
    $OS = [Environment]::OSVersion
}

PROCESS
{
    Write-Debug -Message "PROCESS Block"
    if (-not ($SkipSymlinks))
    {
        forEach ($User in $Users)
        {
            $User = $User.ToLower()
            # Just to ensure we don't have a case-mismatch. Mainly for Linux.
            $SymLinks = @(

                if ($OS.VersionString -match "Windows")
                {
                    #region Windows-based
                    Write-Debug -Message "Windows-based OS: $($OS.VersionString)"
                    @{
                        Source      = "$PSScriptRoot\WindowsPowershell\profile.ps1"
                        Destination = "C:\Users\$User\Documents\WindowsPowershell\profile.ps1"
                        Description = "Windows Powershell profile"
                    }

                    @{
                        Source      = "$PSScriptRoot\pwsh\profile.ps1"
                        Destination = "C:\Users\$User\Documents\Powershell\profile.ps1"
                        Description = "Powershell Core profile"
                    }

                    @{
                        Source      = "$PSScriptRoot\vscode\settings.json"
                        Destination = "C:\Users\$User\AppData\Roaming\Code\User\settings.json"
                        Description = "Visual Studio Code settings"
                    }

                    @{
                        Source      = "$PSScriptRoot\vscode\keybindings.json"
                        Destination = "C:\Users\$User\AppData\Roaming\Code\User\keybindings.json"
                        Description = "Visual Studio Code keybindings"
                    }

                    @{
                        Source      = "$PSScriptRoot\vscode\ansible.json"
                        Destination = "C:\Users\$User\AppData\Roaming\Code\User\snippets\ansible.json"
                        Description = "Visual Studio Code Ansible snippets"
                    }

                    @{
                        Source      = "$PSScriptRoot\vscode\powershell.json"
                        Destination = "C:\Users\$User\AppData\Roaming\Code\User\snippets\powershell.json"
                        Description = "Visual Studio Code Powershell snippets"
                    }

                    @{
                        Source      = "$PSScriptRoot\vim\vimrc"
                        Destination = "C:\Users\$User\_vimrc"
                        Description = "Vim config"
                    }
                    #endregion Windows-based
                }
                else
                {
                    #region Not Windows
                    Write-Debug -Message "Non-Windows OS: $($OS.VersionString)"
                    @{
                        Source      = "$PSScriptRoot/pwsh/profile.ps1"
                        Destination = "/home/$User/.config/powershell/profile.ps1"
                        Description = "Powershell Core profile"
                    }

                    @{
                        Source      = "/home/$User/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
                        Destination = "/home/$User/.ps_history.txt"
                        Description = "PSReadLine history"
                    }

                    @{
                        Source      = "$PSScriptRoot/tmux/.tmux.conf"
                        Destination = "/home/$User/.tmux.conf"
                        Description = "tmux config"
                    }

                    @{
                        Source      = "$PSScriptRoot/tmux/.tmux-default"
                        Destination = "/home/$User/.tmux-default"
                        Description = "tmux Default Session"
                    }

                    @{
                        Source      = "$PSScriptRoot/vscode/settings.json"
                        Destination = "/home/$User/.config/Code/User/settings.json"
                        Description = "Visual Studio Code settings"
                    }

                    @{
                        Source      = "$PSScriptRoot/vscode/keybindings.json"
                        Destination = "/home/$User/.config/Code/User/keybindings.json"
                        Description = "Visual Studio Code keybindings"
                    }

                    @{
                        Source      = "$PSScriptRoot\vscode\ansible.json"
                        Destination = "C:\Users\$User\AppData\Roaming\Code\User\snippets\ansible.json"
                        Description = "Visual Studio Code Ansible snippets"
                    }

                    @{
                        Source      = "$PSScriptRoot/vscode/powershell.json"
                        Destination = "/home/$User/.config/Code/User/snippets/powershell.json"
                        Description = "Visual Studio Code Powershell snippets"
                    }

                    @{
                        Source      = "$PSScriptRoot/vim/vimrc"
                        Destination = "/home/$User/.vimrc"
                        Description = "Vim config"
                    }
                    #endregion
                }
            )


            forEach ($SymLink in $SymLinks)
            {
                # We'll only try and create the link under certain conditions:
                if ((($Exclude) -and ($SymLink.Description -notmatch $Exclude)) -or # If the Exclude parameter is used, and the link doesn't match $Exclude
                    (($Include) -and ($SymLink.Description -match $Include)) -or # If the Include parameter is used, and the link matches $Include
                    (-not ($Exclude -or $Include))) # Or, if we're not using Exclude or Include
                {
                    if ($PSCmdlet.ShouldProcess("$User", "Installing $($SymLink.Description)"))
                    {
                        try
                        {
                            Write-Verbose -Message "Creating symlink for '$($SymLink.Source)' to '$($SymLink.Destination)'"
                            $DestinationFolder = Split-Path -Path $SymLink.Destination

                            # Ensure that any parent directories are created.
                            if (-not (Test-Path -Path $DestinationFolder))
                            {
                                Write-Verbose -Message "Creating directory: '$DestinationFolder'"
                                New-Item -Path $DestinationFolder -ItemType "Directory" | Out-Null
                            }

                            # If Force is used, we'll delete any pre-existing files or symlinks.
                            if ((Test-Path $SymLink.Destination) -and ($Force))
                            {
                                Write-Verbose -Message "Removing existing file ($($SymLink.Destination))"
                                Remove-Item -Path $SymLink.Destination -Force
                            }

                            $Splat = @{
                                Path        = $SymLink.Destination
                                Value       = $SymLink.Source
                                ItemType    = "SymbolicLink"
                                ErrorAction = "Stop"
                            }

                            New-Item @Splat | Out-Null
                        }
                        catch
                        {
                            Write-Warning -Message "There was an issue processing '$($SymLink.Description)'"
                            $PSCmdlet.ThrowTerminatingError($_)
                        }
                    }
                }
                else
                {
                    if (($Exclude) -and ($SymLink.Description -match $Exclude))
                    {
                        Write-Verbose -Message "'$($SymLink.Description)' matches '$Exclude' exclusion regex - Skipping install."
                    }
                    elseif (($Include) -and ($SymLink.Description -notmatch $Include))
                    {
                        Write-Verbose -Message "'$($SymLink.Description)' does not match '$Include' inclusion regex - Skipping install."
                    }
                    else
                    {
                        Write-Verbose -Message "Unexpected condition. Skipping install."
                    }
                }
            }
        }
    }
    else
    {
        Write-Verbose -Message "Skipping installation of all sym-links."
    }

    if (($InstallVSCodeExtensions) -and
        (Get-Command "code" -ErrorAction "SilentlyContinue" | Where-Object CommandType -match "^App" | Where-Object Source -match "VS Code"))
    {
        Write-Verbose -Message "Installing Visual Studio Code extensions for the current user."
        try
        {
            $GetExtensionsSplat = @{
                Path        = "$PSScriptRoot\vscode\extensions.txt"
                ErrorAction = "Stop"
            }
        }
        catch
        {
            Write-Warning -Message "Unable to read the extensions list."
            $PSCmdlet.ThrowTerminatingError($_)
        }

        $Extensions = Get-Content @GetExtensionsSplat
        forEach ($Extension in $Extensions)
        {
            if ($PSCmdlet.ShouldProcess([Environment]::UserName, "Installing '$Extension' extension"))
            {
                code --install-extension $Extension --Force
            }
        }
    }
    else
    {
        if (-not (Get-Command "code" -ErrorAction "SilentlyContinue" | Where-Object CommandType -match "^App" | Where-Object Source -match "VS Code"))
        {
            Write-Warning -Message "The expected 'code' command was not found by Powershell."
        }
        elseif (-not (Get-Command "code" -ErrorAction "SilentlyContinue"))
        {
            Write-Warning -Message "No 'code' command was found by Powershell."
        }
    }
}

END
{
    Write-Debug -Message "END Block"
}