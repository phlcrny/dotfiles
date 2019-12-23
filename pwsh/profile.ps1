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
            Name        = "devicemanager"
            Value       = "hdwwiz.cpl"
            Description = "Alias for the Device Manager Control Panel applet."
        }
    }

    @{
        Name        = "gd"
        Value       = "Get-Date"
        Description = "Short-hand for the Get-Date cmdlet."
    }

    @{
        Name        = "gfh"
        Value       = "Get-Help"
        Description = "Alias to replace an old custom function."
    }

    @{
        Name        = "Hosts"
        Value       = $Hosts
        Description = "Short-hand for the Hosts file."
    }
)

forEach ($_Alias in $_NewAliases)
{
    if (-not ((Test-Path -Path "alias:\$($_Alias.Name)" -ErrorAction "SilentlyContinue") -and
            (Get-Command -Name $_Alias.Name -ErrorAction "SilentlyContinue")))
    {
        $_AliasSplat = @{
            Name        = $_Alias.Name
            Value       = $_Alias.Value
            Description = $_Alias.Description
        }

        New-Alias @_AliasSplat
    }
}

# PSReadline
Set-PSReadLineOption -BellStyle "None"
Set-PSReadLineKeyHandler -Key "Tab" -Function "MenuComplete"
Set-PSReadLineKeyHandler -Key "UpArrow" -Function "HistorySearchBackward"
Set-PSReadLineKeyHandler -Key "DownArrow" -Function "HistorySearchForward"

if (Test-Path "$PSScriptRoot\work_extras.ps1" -ErrorAction "SilentlyContinue")
{
    # Adds work-specific items, not for public consumption.
    . (Join-Path -Path $PSScriptRoot -ChildPath "work_extras.ps1")
}

# Clear-host at start-up
[Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()

# Variable clean-up.
Remove-Variable "_Alias", "_AliasSplat", "_CurrentUser", "_NewAliases" -ErrorAction "SilentlyContinue"