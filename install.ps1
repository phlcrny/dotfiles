<#
.SYNOPSIS
    Installs dotfiles and configuration options.
.DESCRIPTION
    Installs dotfiles using symbolic links to the repository or file copies from the repository.
.PARAMETER User
    The user or users who will have the dotfiles installed in their directories. This defaults to the current user.
.PARAMETER InstallSymlinks
    Installs dotfiles using symlinks - requires admin access on Windows
.PARAMETER InstallCopies
    Installs dotfiles using file copies.
.PARAMETER InstallVSCodeExtensions
    Installs VS Code extensions for the current user
.PARAMETER Include
    Includes only dotfiles whose descriptions match this regular expression pattern.
.PARAMETER Exclude
    Excludes dotfiles whose descriptions match this regular expression pattern.
.PARAMETER Backup
    Backs up any existing dotfiles in-place before installing from the repository.
.PARAMETER Force
    Overwrites any existing symlinks/files, if Backup is also specified, this runs after the backup.
.EXAMPLE
    . ./install.ps1 -InstallSymlinks -User "Me", "You"

    Installs the dotfiles for users 'Me' and 'You' using Symlinks
.EXAMPLE
    . ./install.ps1 -InstallCopies -User "Me", "You"

    Installs the dotfiles for users 'Me' and 'You' using file copies
.INPUTS
    Strings (optional) and Switches (optional)
.OUTPUTS
    N/A
.NOTES
    Version 2.0.0

    Note: This install script is not tested with macOS.
.LINK
    https://github.com/philccarney/dotfiles
#>
[CmdletBinding(ConfirmImpact = 'Low', SupportsShouldProcess = $True, DefaultParameterSetName = "Default")] # Bit rusty with parameter sets, but this seems to work.
[Alias()]
[OutputType()]
param
(
    [Parameter(Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The user(s) the dotfiles will be installed for. Defaults to the current user.")]
    [string[]] $User,

    [Parameter(HelpMessage = "Installs dotfiles by creating symlinks from the repository", ParameterSetName = "Symlinks")]
    [switch] $InstallSymlinks,

    [Parameter(HelpMessage = "Installs dotfiles by copying files from the repository", ParameterSetName = "Copies")]
    [switch] $InstallCopies,

    [Parameter(HelpMessage = "Installs the vscode extensions for the current user.")]
    [switch] $InstallVSCodeExtensions,

    [Parameter(HelpMessage = "Only symlinks whose descriptions match this string will be installed. Uses regular expression.")]
    [string] $Include,

    [Parameter(HelpMessage = "Any symlinks whose descriptions match this string will not be installed. Uses regular expression.")]
    [string] $Exclude,

    [Parameter(HelpMessage = "Backs up any existing symlinks/files to be overwritten.")]
    [switch] $Backup,

    [Parameter(HelpMessage = "Overwrites any existing symlinks/files.")]
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

    Write-Debug -Message "Determining 'OS' version."
    $OS = [Environment]::OSVersion
}

PROCESS
{
    Write-Debug -Message "PROCESS Block"
    if (($InstallSymlinks) -or ($InstallCopies))
    {
        forEach ($User in $Users)
        {
            $User = $User.ToLower()
            # Just to ensure we don't have a case-mismatch. Mainly for Linux.
            $Files = @(
                @{
                        Source      = "$PSScriptRoot/WindowsPowershell/profile.ps1"
                        WindowsDestination = "C:/Users/$User/Documents/WindowsPowershell/profile.ps1"
                        Description = "Windows Powershell profile"
                    }

                    @{
                        Source      = "$PSScriptRoot/pwsh/profile.ps1"
                        WindowsDestination = "C:/Users/$User/Documents/Powershell/profile.ps1"
                        UnixDestination = "/home/$User/.config/powershell/profile.ps1"
                        Description = "Powershell Core profile"
                    }

                    @{
                        Source      = "/home/$User/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
                        UnixDestination = "/home/$User/.ps_history.txt"
                        Description = "PSReadLine (Unix) history"
                    }

                    @{
                        Source      = "C:/Users/$User/AppData/Roaming/Microsoft/Windows/PowerShell/PSReadline/ConsoleHost_history.txt"
                        WindowsDestination = "/home/$User/.ps_history.txt"
                        Description = "PSReadLine (Windows) history"
                    }

                    @{
                        Source = "$PSScriptRoot/git/gitconfig"
                        UnixDestination = "/home/$User/.gitconfig"
                        WindowsDestination = "C:/Users/$User/.gitconfig"
                        Description = "Git User Config"
                    }

                    @{
                        Source      = "$PSScriptRoot/tmux/.tmux.conf"
                        UnixDestination = "/home/$User/.tmux.conf"
                        Description = "tmux config"
                    }

                    @{
                        Source      = "$PSScriptRoot/vscode/settings.json"
                        UnixDestination = "/home/$User/.config/Code/User/settings.json"
                        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/settings.json"
                        Description = "Visual Studio Code settings"
                    }

                    @{
                        Source      = "$PSScriptRoot/vscode/keybindings.json"
                        UnixDestination = "/home/$User/.config/Code/User/keybindings.json"
                        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/keybindings.json"
                        Description = "Visual Studio Code keybindings"
                    }

                    @{
                        Source      = "$PSScriptRoot/vscode/ansible.json"
                        UnixDestination = "/home/$User/.config/Code/User/snippets/ansible.json"
                        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/snippets/ansible.json"
                        Description = "Visual Studio Code Ansible snippets"
                    }

                    @{
                        Source      = "$PSScriptRoot/vscode/powershell.json"
                        UnixDestination = "/home/$User/.config/Code/User/snippets/powershell.json"
                        WindowsDestination = "C:/Users/$User/AppData/Roaming/Code/User/snippets/powershell.json"
                        Description = "Visual Studio Code Powershell snippets"
                    }

                    @{
                        Source      = "$PSScriptRoot/vim/vimrc"
                        UnixDestination = "/home/$User/.vimrc"
                        WindowsDestination = "C:/Users/$User/_vimrc"
                        Description = "Vim config"
                    }

                    @{
                        Source = "$PSScriptRoot/WindowsTerminal/profiles.json"
                        WindowsDestination = "C:/Users/$User/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/RoamingState/profiles.json"
                        Description = "Windows Terminal settings"
                    }
            )

            forEach ($File in $Files)
            {
                # We'll only try and create the link under certain conditions:
                # If the Exclude parameter is used, and the link doesn't match $Exclude
                # If the Include parameter is used, and the link matches $Include
                # Or, if we're not adding restrictions at all (i.e. Exclude or Include are not specified)
                if ((-not ($Exclude -or $Include)) -or
                    (($Include) -and ($File.Description -match $Include)) -or
                    (($Exclude) -and ($File.Description -notmatch $Exclude)))
                {
                    Write-Verbose -Message "Processing $($File.Description)"
                            # Begin install scaffolding, this is expanded based on parameter choices
                            $Splat = @{
                                ErrorAction = "Stop"
                            }

                            # This should allow us to use the script against Windows and non-Windows without maintaining
                            # two different lists and/or two different install mechanisms
                            if (($OS.VersionString -match "Windows") -and ($File.WindowsDestination))
                            {
                                $Destination = $File.WindowsDestination
                            }
                            elseif (($OS.VersionString -notmatch "Windows") -and ($File.UnixDestination))
                            {
                                $Destination = $File.UnixDestination
                            }
                            else
                            {
                                # Skip entirely if the item doesn't have a viable destination for the current OS
                                Continue
                            }

                            # Ensure that any parent directories are created.
                            $DestinationFolder = Split-Path -Path $Destination
                            if (-not (Test-Path -Path $DestinationFolder))
                            {
                                if ($PSCmdlet.ShouldProcess($DestinationFolder, "Creating target directory"))
                                {
                                    try
                                    {
                                        [void] (New-Item -Path $DestinationFolder -ItemType "Directory")
                                    }
                                    catch
                                    {
                                        $PSCmdlet.ThrowTerminatingError($_)
                                    }
                                }
                            }

                            if (Test-Path $Destination)
                            {
                                if ($Backup)
                                {
                                    try
                                    {
                                        Write-Verbose -Message "Determining backup file name"
                                        $Target = Get-Item -Path $Destination
                                        $NewName = ($Target.BaseName + "$(Get-Date -UFormat "-%H%M-%d%m%Y")" + $Target.Extension)
                                    }
                                    catch
                                    {
                                        $PSCmdlet.ThrowTerminatingError($_)
                                    }

                                    if ($PSCmdlet.ShouldProcess($NewName, "Backing up $($File.Description)"))
                                    {
                                        try
                                        {
                                            $BackupSplat = @{
                                                Path = $File.FullName
                                                Destination = (Join-Path -Path $Target.Directory.FullName -ChildPath $NewName)
                                                Force = $True
                                            }

                                            Copy-Item @BackupSplat
                                        }
                                        catch
                                        {
                                            $PSCmdlet.ThrowTerminatingError($_)
                                        }
                                    }
                                }

                                if ($Force)
                                {
                                    $Splat.Add("Force", $True)
                                    Write-Verbose -Message "Removing existing file ($Destination)"
                                    Remove-Item -Path $Destination -Force
                                }
                            }

                            if ($InstallSymlinks)
                            {
                                if ($PSCmdlet.ShouldProcess($Destination, "Creating symlink for '$($File.Source)'"))
                                {
                                    try
                                    {
                                        $Splat.Add("Path", $Destination)
                                        $Splat.Add("Value", $File.Source)
                                        $Splat.Add("ItemType", "SymbolicLink")
                                        [void] (New-Item @Splat)
                                    }
                                    catch
                                    {
                                        $PSCmdlet.ThrowTerminatingError($_)
                                    }
                                }

                            }
                            elseif ($InstallCopies)
                            {
                                $Splat.Add("Destination", $Destination)
                                $Splat.Add("Path", $File.Source)
                                [void] (Copy-Item @Splat)
                            }
                    }
                }
                else
                {
                    if (($Exclude) -and ($File.Description -match $Exclude))
                    {
                        Write-Verbose -Message "'$($File.Description)' matches '$Exclude' exclusion regex - Skipping install."
                    }
                    elseif (($Include) -and ($File.Description -notmatch $Include))
                    {
                        Write-Verbose -Message "'$($File.Description)' does not match '$Include' inclusion regex - Skipping install."
                    }
                    else
                    {
                        Write-Verbose -Message "Unexpected condition. Skipping install."
                    }
                }
        }
    }

    if (($InstallVSCodeExtensions) -and
        (Get-Command "code" -ErrorAction "SilentlyContinue" | Where-Object Source -match "VS Code"))
    {
        Write-Verbose -Message "Installing Visual Studio Code extensions for '$([System.Environment]::UserName)'"
        try
        {
            $GetExtensionsSplat = @{
                Path        = "$PSScriptRoot/vscode/extensions"
                ErrorAction = "Stop"
            }

            $Extensions = Get-Content @GetExtensionsSplat
        }
        catch
        {
            Write-Warning -Message "Unable to read the extensions list."
            $PSCmdlet.ThrowTerminatingError($_)
        }

        forEach ($Extension in $Extensions)
        {
            if ($PSCmdlet.ShouldProcess([Environment]::UserName, "Installing '$Extension' extension"))
            {
                code --install-extension $Extension
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