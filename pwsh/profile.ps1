[string] $_CurrentUser = "$([Environment]::UserDomainName)\$([Environment]::UserName)"
[string] $_Titlebar = "$_CurrentUser - $(($ExecutionContext.SessionState.Path.CurrentLocation.Path) -split "::" | Select-Object -Last 1)"
$Host.UI.RawUI.WindowTitle = $_Titlebar

if (Get-Module -Name "Posh-Git" -ListAvailable -ErrorAction "SilentlyContinue")
{
    [void] (Import-Module -Name "Posh-Git")
    $_PoshGit = $True
}

# Aliases and preferences

# Aliases
$_NewAliases = @(

    if ($Null -ne (Get-Command "hdwwiz.cpl" -ErrorAction "SilentlyContinue"))
    {
        @{
            Name  = "devicemanager"
            Value = "hdwwiz.cpl"
        }
    }

    @{
        Name  = "ssps"
        Value = "Enter-PSSession"
    }

    @{
        Name  = "gd"
        Value = "Get-Date"
    }

    @{
        Name  = "gfh"
        Value = "Get-Help"
    }

    $(
        if (Get-Module -Name "Plaster" -ListAvailable)
        {
            @{
                Name  = "Plaster"
                Value = "Invoke-Plaster"
            }
        }
    )

    $(
        if (Test-Path "C:\Program Files\Git\usr\bin\vim.exe")
        {
            @{
                Name  = "vim"
                Value = "C:\Program Files\Git\usr\bin\vim.exe"
            }
        }
    )
)

forEach ($_Alias in $_NewAliases)
{
    if (-not ((Test-Path -Path "alias:\$($_Alias.Name)" -ErrorAction "SilentlyContinue") -and
            (Get-Command -Name $_Alias.Name -ErrorAction "SilentlyContinue")))
    {
        $_AliasSplat = @{
            Name  = $_Alias.Name
            Value = $_Alias.Value
        }

        New-Alias @_AliasSplat
    }
}

# PSReadline
$_HistoryHandlerScriptBlock = {
    param(
        [string] $Line
    )

    $SkipExclusion = "skip_pshistory"
    $Exclusions = @(
        "powershell_ise"
    )

    if (($Line.ToLower() -notmatch $SkipExclusion) -and ($Line.Length -ge 4))
    {
        if ($Line.ToLower() -notin $Exclusions)
        {
            $True
        }
        else
        {
            $False
        }
    }
    else
    {
        $False
    }
}
$_ReadlineOptions = @{
    AddToHistoryHandler           = $_HistoryHandlerScriptBlock
    BellStyle                     = "None"
    HistoryNoDuplicates           = $True
    HistorySearchCursorMovesToEnd = $True
    ShowTooltips                  = $False
}
if (Get-Module "PSReadline" | Where-Object Version -ge 2.1.0)
{
    $_ReadlineOptions.Add("PredictionSource", "History")
}

Set-PSReadLineOption @_ReadlineOptions
Set-PSReadLineKeyHandler -Key "Tab" -Function "MenuComplete"
Set-PSReadLineKeyHandler -Key "UpArrow" -Function "HistorySearchBackward"
Set-PSReadLineKeyHandler -Key "DownArrow" -Function "HistorySearchForward"
$ENV:POWERSHELL_UPDATECHECK = "LTS"

# Default Parameter Values
$PSDefaultParameterValues = @{
    "Format-Table:AutoSize" = $True
    "Get-Help:Full"         = $True
    "Invoke-Plaster:NoLogo" = $True
    "New-Item:ItemType"     = "File"
    "Set-Location:Path"     = $HOME
}

# Via Mathias Jessen:
# https://stackoverflow.com/a/68314618/11838387
$ExecutionContext.InvokeCommand.CommandNotFoundAction = {
    param(
        [string] $CommandName,
        [System.Management.Automation.CommandLookupEventArgs] $EventArgs
    )

    # Test if the "command" in question is actually a directory path
    if (Test-Path $CommandName -PathType Container)
    {
        # Tell PowerShell to execute Set-Location against it instead
        $EventArgs.CommandScriptBlock = {
            Set-Location $CommandName
        }.GetNewClosure()
        # Tell PowerShell that we've provided an alternative, it can stop looking for commands (and stop throwing the error)
        $EventArgs.StopSearch = $true
    }
}

if (Get-Command "starship" -ErrorAction "SilentlyContinue")
{
    Invoke-Expression (&starship init powershell)
}

if (Test-Path (Join-Path -Path $PSScriptRoot -ChildPath "extras.ps1") -ErrorAction "SilentlyContinue")
{
    # Adds items not for public consumption - work-specific etc
    . (Join-Path -Path $PSScriptRoot -ChildPath "extras.ps1")
}

# Variable clean-up.
Remove-Variable "_Alias", "_AliasSplat", "_CurrentUser", "_NewAliases" -ErrorAction "SilentlyContinue"
