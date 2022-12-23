<#
.SYNOPSIS
    Uninstalls the dotfiles' symbolic links.
.DESCRIPTION
    Uses the 'Remove-Item' cmdlet to delete symbolic links created between individual dotfiles and their expected 'real' locations.
.PARAMETER User
    The user or users who will have the dotfiles uninstalled from their directories. This defaults to the current user.
.PARAMETER Include
    Includes only dotfiles whose descriptions match this regular expression pattern.
.PARAMETER Exclude
    Excludes dotfiles whose descriptions match this regular expression pattern.
.EXAMPLE
    . .\uninstall.ps1 -User "Me", "You"

    Installs the dotfiles for users 'Me' and 'You'.
.INPUTS
    Strings (optional)
.OUTPUTS
    N/A
.LINK
    https://github.com/phlcrny/dotfiles
#>
[CmdletBinding(ConfirmImpact = 'Low', SupportsShouldProcess = $True)]
param
(
    [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = "The user(s) the dotfiles will be installed for")]
    [string[]] $User = [System.Environment]::UserName,

    [Parameter(HelpMessage = "Only symlinks whose descriptions match this string will be uninstalled. Uses regular expression.")]
    [string] $Include,

    [Parameter(HelpMessage = "Any symlinks whose descriptions match this string will not be uninstalled. Uses regular expression.")]
    [string] $Exclude
)

BEGIN
{
    if ($PSBoundParameters.ContainsKey("Debug"))
    {
        $DebugPreference = "Continue"
    }
    Write-Debug -Message "BEGIN Block"

    Write-Debug -Message "Determining 'OS' version."
    $OS = [Environment]::OSVersion
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

                if (($OS.VersionString -match 'Windows') -and ($File.WindowsDestination))
                {
                    $Destination = $File.WindowsDestination
                }
                else
                {
                    $Destination = if (($IsLinux) -and ($File.UnixDestination))
                    {
                        $File.UnixDestination
                    }
                    elseif (($IsMacOS) -and ($File.MacDestination))
                    {
                        $File.MacDestination
                    }
                    else
                    {
                        Continue
                    }
                }

                if ($PSCmdlet.ShouldProcess($Destination, "Uninstalling '$($File.Description)' for '$User'"))
                {
                    if (Test-Path -Path $Destination)
                    {
                        try
                        {
                            Write-Verbose -Message "Removing sym-link/file for '$($File.Source)' from '$Destination"
                            Remove-Item -Path $Destination -Force
                        }
                        catch
                        {
                            Write-Warning -Message "There was an issue processing '$($File.Description)'"
                            $PSCmdlet.ThrowTerminatingError($_)
                        }
                    }
                    else
                    {
                        Write-Verbose -Message "Unable to locate '$($File.Description)'. Moving on."
                    }
                }
            }
        }
    }
}

END
{
    Write-Debug -Message "END Block"
}
