# Font:
# Consolas, 14

[string] $_CurrentUser = "$([Environment]::UserDomainName)\$([Environment]::UserName)"
[string] $_Titlebar = "$_CurrentUser - $(($ExecutionContext.SessionState.Path.CurrentLocation.Path) -split "::" | Select-Object -Last 1)"
$Host.UI.RawUI.WindowTitle = $_Titlebar
$_SmallScreenPrompt = $False

function prompt
{
    [string] $_PromptHost = [Environment]::MachineName
    [string] $_PromptUser = [Environment]::UserName

    function Format-CurrentPath ($Path)
    {
        switch -regex ($Path)
        {
            "^C:\\Users\\$_PromptUser"
            {
                $Path -replace "^C:\\Users\\$_PromptUser", "~"
                Continue
            }

            "^C:\\"
            {
                $Path -replace "^C:\\", "\"
                Continue
            }

            "^Microsoft.PowerShell.Core\\FileSystem\:\:"
            {
                $Path -replace "^Microsoft.PowerShell.Core\\FileSystem\:\:"
                Continue
            }

            default
            {
                $Path
            }
        }
    }

    $_CurrentLocation = Format-CurrentPath -Path $ExecutionContext.SessionState.Path.CurrentLocation
    $_SimulatedPrompt = "$_PromptUser on $_PromptHost at $_CurrentLocation"
    $(
        if (Test-Path -Path "Variable:\PSDebugContext")
        {
            $('[DBG]: ' | Write-Host -ForegroundColor "Green" -NoNewline)
        }
        else
        {
            ''
        }
    ) +
    $($_PromptUser | Write-Host -NoNewline -ForegroundColor "Cyan") +
    $(" on " | Write-Host -NoNewline) +
    $($_PromptHost | Write-Host -NoNewline -ForegroundColor "Green") +
    $(" in " | Write-Host -NoNewline) +
    $($_CurrentLocation | Write-Host -ForegroundColor "Magenta" -NoNewline) +
    $(
        if (($_SimulatedPrompt.Length -ge 80) -or
            ($_SmallScreenPrompt)) # I don't want to have my commands wrap on to another line just because of a long path.
        {
            " " + $(Write-Host "") + $("$" | Write-Host -ForegroundColor "Cyan" -NoNewline)
        }
        else
        {
            $(" $" | Write-Host -ForegroundColor "Cyan" -NoNewline)
        }
    ) + " "
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

    if (($Line.ToLower() -notmatch $SkipExclusion) -or ($Line.Length -ge 4))
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
    HistorySavePath               = "$HOME\.ps_history.txt"
    HistorySearchCursorMovesToEnd = $True
    ShowTooltips                  = $False
}
Set-PSReadLineOption @_ReadlineOptions
Set-PSReadLineKeyHandler -Key "Tab" -Function "MenuComplete"
Set-PSReadLineKeyHandler -Key "UpArrow" -Function "HistorySearchBackward"
Set-PSReadLineKeyHandler -Key "DownArrow" -Function "HistorySearchForward"

# Default Parameter Values
$PSDefaultParameterValues = @{
    "Format-Table:AutoSize" = $True
    "Get-Help:Full"         = $True
    "Invoke-Plaster:NoLogo" = $True
    "New-Item:ItemType"     = "File"
    "Set-Location:Path"     = $HOME
}

if (Test-Path (Join-Path -Path $PSScriptRoot -ChildPath "extras.ps1") -ErrorAction "SilentlyContinue")
{
    # Adds items not for public consumption - work-specific etc
    . (Join-Path -Path $PSScriptRoot -ChildPath "extras.ps1")
}

# Variable clean-up.
Remove-Variable "_Alias", "_AliasSplat", "_CurrentUser", "_NewAliases" -ErrorAction "SilentlyContinue"