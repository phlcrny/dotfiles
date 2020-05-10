<#
.SYNOPSIS
    Uninstalls the dotfiles' symbolic links.
.DESCRIPTION
    Uses the 'Remove-Item' cmdlet to delete symbolic links created between individual dotfiles and their expected 'real' locations.
.PARAMETER User
    The user or users who will have the dotfiles uninstalled from their directories. This defaults to the current user.
.EXAMPLE
    . .\uninstall.ps1 -User "Me", "You"

    Installs the dotfiles for users 'Me' and 'You'.
.INPUTS
    Strings (optional)
.OUTPUTS
    N/A
.NOTES
    Version 1.0.0
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
        # Just to ensure we don't have a case-mismatch. Mainly for Linux.
        $User = $User.ToLower()
        # For ease of maintenance for install and uninstall, the files are loaded from an external file.
        $Files = @(. (Join-Path -Path $PSScriptRoot -ChildPath "files.ps1"))
        forEach ($File in $Files)
        {
            if ($PSCmdlet.ShouldProcess("$User", "Uninstalling $($File.Description)"))
            {
                if (Test-Path -Path $File.Destination)
                {
                    try
                    {
                        Write-Verbose -Message "Removing sym-link for '$($File.Source)' from '$($File.Destination)'"
                        Remove-Item -Path $File.Destination -Force # Testing some permission issues.
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

END
{
    Write-Debug -Message "END Block"
}