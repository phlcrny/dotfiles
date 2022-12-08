<#
.SYNOPSIS
    Installs dotfiles and configuration options.
.DESCRIPTION
    Installs dotfiles using symbolic links to the repository or file copies from the repository.
.PARAMETER User
    The user or users who will have the dotfiles installed in their directories. This defaults to the current user.
.PARAMETER Type
    Determines if the dotfiles will be installed as symlinks or file copies
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
.LINK
    https://github.com/phlcrny/dotfiles
#>
[CmdletBinding(ConfirmImpact = 'Low', SupportsShouldProcess = $True, DefaultParameterSetName = "Default")] # Bit rusty with parameter sets, but this seems to work.
[Alias()]
[OutputType()]
param
(
    [Parameter(Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The user(s) the dotfiles will be installed for. Defaults to the current user")]
    [string[]] $User = [System.Environment]::UserName,

    [Parameter(HelpMessage = "How the dotfiles will be installed - symlinks or file copies")]
    [alias("InstallType")]
    [ValidateSet('Symlinks', 'Copies')]
    [string] $Type = 'Symlink',

    [Parameter(HelpMessage = "Installs the vscode extensions for the current user")]
    [switch] $InstallVSCodeExtensions,

    [Parameter(HelpMessage = "Installs vim plugins")]
    [switch] $InstallVimPlugins,

    [Parameter(HelpMessage = "Only symlinks whose descriptions match this string will be installed. Uses regular expression")]
    [string] $Include,

    [Parameter(HelpMessage = "Any symlinks whose descriptions match this string will not be installed. Uses regular expression")]
    [string] $Exclude,

    [Parameter(HelpMessage = "Backs up any existing symlinks/files to be overwritten")]
    [switch] $Backup,

    [Parameter(HelpMessage = "Overwrites any existing symlinks/files")]
    [switch] $Force
)

BEGIN
{
    if ($PSBoundParameters.ContainsKey("Debug"))
    {
        $DebugPreference = "Continue"
    }
    Write-Debug -Message "Determining 'OS' version."
    $OS = [Environment]::OSVersion
    $Users = @($User) # Awful but parameter names vs variable names
}

PROCESS
{
    Write-Debug -Message "PROCESS Block"
    forEach ($User in $Users)
    {
        # Just to ensure we don't have a case-mismatch. Mainly for Linux.
        $User = $User.ToLower()
        Write-Verbose -Message "Processing '$User'"
        # For ease of maintenance for install and uninstall, the files are loaded from an external file.
        $Files = @(. (Join-Path -Path $PSScriptRoot -ChildPath "files.ps1"))
        forEach ($File in $Files)
        {
            # We'll only try and install under certain conditions:
            # If the Exclude parameter is used, and the file doesn't match $Exclude
            # If the Include parameter is used, and the file matches $Include
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
                                    Path        = $File.FullName
                                    Destination = (Join-Path -Path $Target.Directory.FullName -ChildPath $NewName)
                                    Force       = $True
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
                    else
                    {
                        if (Test-Path -Path $Destination)
                        {
                            Write-Warning -Message "$($File.Description) already exists. Skipping."
                            Continue
                        }
                    }
                }

                if ($Type -like 'Symlinks')
                {
                    Write-Verbose -Message "Installing symlink for '$($File.Source)'"
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
                elseif ($Type -like 'Copies')
                {
                    $Splat.Add("Destination", $Destination)
                    $Splat.Add("Path", $File.Source)
                    [void] (Copy-Item @Splat)
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

    if ((($InstallVimPlugins)) -and
        ((Get-Command 'git' -ErrorAction 'SilentlyContinue') -and (Get-Command 'vim' -ErrorAction 'SilentlyContinue')))
    {
        Write-Verbose -Message "Installing Vim plugins for '$([System.Environment]::UserName)'"
        $VimPluginDirCandidates = $Files |
            Where-Object 'WindowsDestination' -Like '*/.vim/pack/*' |
            Select-Object -First 1
        $VimPluginDir = if ($OS.VersionString -match 'Windows')
        {
            $VimPluginDirCandidates.WindowsDestination
        }
        elseif (Test-Path -Path '/Users/')
        {
            $VimPluginDirCandidates.MacDestination
        }
        elseif (Test-Path -Path '/home/')
        {
            $VimPluginDirCandidates.UnixDestination
        }

        if (-not (Test-Path (Join-Path -Path $VimPluginDir -ChildPath 'dracula')))
        {
            git clone --quiet https://github.com/dracula/vim.git (Join-Path -Path $VimPluginDir -ChildPath 'dracula')
        }
        else
        {
            Write-Verbose -Message 'Dracula theme already installed for Vim'
        }

        if (-not (Test-Path (Join-Path -Path $VimPluginDir -ChildPath 'vim-airline')))
        {
            git clone --quiet https://github.com/vim-airline/vim-airline.git (Join-Path -Path $VimPluginDir -ChildPath 'vim-airline')
            vim -u NONE -c "helptags $(Join-Path -Path $VimPluginDir -ChildPath 'vim-airline/doc')" -c q
        }
        else
        {
            Write-Verbose -Message 'vim-airline plugin already installed for Vim'
        }

        if (-not (Test-Path (Join-Path -Path $VimPluginDir -ChildPath 'vim-ps1')))
        {
            git clone --quiet https://github.com/PProvost/vim-ps1.git (Join-Path -Path $VimPluginDir -ChildPath 'vim-ps1')
        }
        else
        {
            Write-Verbose -Message 'vim-ps1 plugin already installed for Vim'
        }

        if (-not (Test-Path (Join-Path -Path $VimPluginDir -ChildPath 'nerdtree')))
        {
            git clone --quiet https://github.com/preservim/nerdtree.git (Join-Path -Path $VimPluginDir -ChildPath 'nerdtree')
            vim -u NONE -c "helptags $(Join-Path -Path $VimPluginDir -ChildPath 'nerdtree/doc')" -c q
        }
        else
        {
            Write-Verbose -Message 'Nerdtree plugin already installed for Vim'
        }
    }
    else
    {
        if (-not (Get-Command 'vim' -ErrorAction 'SilentlyContinue'))
        {
            Write-Warning -Message "The expected 'vim' command was not found by Powershell."
        }
        elseif (-not (Get-Command 'git' -ErrorAction 'SilentlyContinue'))
        {
            Write-Warning -Message "The expected 'git' command was not found by Powershell."
        }
    }
}

END
{
    Write-Debug -Message "END Block"
}
