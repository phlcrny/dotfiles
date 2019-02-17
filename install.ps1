<#
.SYNOPSIS
    Installs the dotfiles with symbolic links to the relevant locations.
.DESCRIPTION
    Uses the 'New-Item' cmdlet to create symbolic links between individual dotfiles and their expected 'real' locations.
.PARAMETER User
    The user or users who will have the dotfiles installed in their directories. This defaults to the current user.
.EXAMPLE
    . .\install.ps1 -User "Me", "You"

    Installs the dotfiles for users 'Me' and 'You'.
.INPUTS
    Strings (optional)
.OUTPUTS
    N/A
.NOTES
    Version 0.1.0

    Note: This install script is not intended for use with macOS.
.LINK
    https://github.com/philccarney/dotfiles
#>
[CmdletBinding(ConfirmImpact = 'Low', SupportsShouldProcess = $True)]
param
(
    [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The user(s) the dotfiles will be installed for")]
    [string[]] $User
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

    Write-Debug -Message "Determining 'OS' version."
    $OS = [Environment]::OSVersion
}

PROCESS
{
    Write-Debug -Message "PROCESS Block"
    forEach ($User in $Users)
    {
        $SymLinks = @(

            if ($OS.VersionString -match "Windows")
            {
                #region Windows-based
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
                $User = $User.ToLower() # Just to ensure we don't have a case-mismatch.
                @{
                    Source      = "$PSScriptRoot/pwsh/profile.ps1"
                    Destination = "/home/$User/.config/powershell/profile.ps1"
                    Description = "Powershell Core profile"
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
            if ($PSCmdlet.ShouldProcess("$User", "Installing $($SymLink.Description)"))
            {
                try
                {
                    Write-Verbose -Message "Creating sym-link for '$($SymLink.Source)' to '$($SymLink.Destination)'"
                    $DestinationFolder = Split-Path -Path $SymLink.Destination
                    if (-not (Test-Path -Path $DestinationFolder))
                    {
                        Write-Verbose -Message "Creating directory: '$DestinationFolder'"
                        New-Item -Path $DestinationFolder -ItemType "Directory" | Out-Null
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
    }
}

END
{
    Write-Debug -Message "END Block"
}