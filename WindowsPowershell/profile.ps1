# Determine if current user is an Administrator
$CurrentUserID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentUserID)
$Admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$UserIsAdmin = $WindowsPrincipal.IsInRole($Admin)
# Force Powershell to use TLS 1.2 for HTTPS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Lazy variable
$Hosts = "C:\Windows\System32\drivers\etc\hosts"

# Aliases and preferences

# Aliases
$NewAliases = @(

    @{
        Name  = "~"
        Value = $HOME
    }

    @{
        Name  = "devicemanager"
        Value = "hdwwiz.cpl"
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

    @{
        Name  = "grep"
        Value = "Select-String"
    }

    @{
        Name  = "Hosts"
        Value = $Hosts
    }

    @{
        Name  = "Import"
        Value = "Import-Module"
    }

    @{
        Name  = "Touch"
        Value = "New-Item"
    }

    @{
        Name  = "Plaster"
        Value = "Invoke-Plaster"
    }

    @{
        Name  = "vim"
        Value = "C:\Program Files\Git\usr\bin\vim.exe"
    }
)

forEach ($Alias in $NewAliases)
{
    if (-not (Test-Path -Path "alias:\$($Alias.Name)" -ErrorAction "SilentlyContinue"))
    {
        $AliasSplat = @{
            Name  = $Alias.Name
            Value = $Alias.Value
        }

        New-Alias @AliasSplat
    }
}

# Preferences

# PSReadline
if (Get-Command "Set-PSReadlineKeyHandler" -ErrorAction "SilentlyContinue")
{
    $_HistoryHandlerScriptBlock = {
        param(
            [string] $Line
        )

        $SkipExclusion = "skip_pshistory"
        $Exclusions = @(
            "powershell_ise"
        )

        if (($Line.ToLower() -notmatch $SkipExclusion) -and
            ($Line.Length -ge 4))
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
    $HasPSReadline = $True
    $_ReadlineOptions = @{
        AddToHistoryHandler           = $_HistoryHandlerScriptBlock
        BellStyle                     = "None"
        ExtraPromptLineCount          = 1
        HistoryNoDuplicates           = $True
        HistorySearchCursorMovesToEnd = $True
        ShowTooltips                  = $False
    }
    Set-PSReadLineOption @_ReadlineOptions
    Set-PSReadLineKeyHandler -Key "Tab" -Function "MenuComplete"
    # Set zsh-style tab-complete
    Set-PSReadLineKeyHandler -Key "UpArrow" -Function "HistorySearchBackward"
    Set-PSReadLineKeyHandler -Key "DownArrow" -Function "HistorySearchForward"
    # Amend default search behaviour

    # Custom bindings
    Set-PSReadLineKeyHandler -Chord "Ctrl+Shift+P" -Description "Opens the folder where your profile is saved." -ScriptBlock {
        $_ProfileObject = Get-Item $Profile.CurrentUserAllHosts
        if ($_ProfileObject.LinkType -like "SymbolicLink")
        {
            Invoke-Item (Split-Path -Path $_ProfileObject.Target)
        }
        else
        {
            Invoke-Item (Split-Path -Path $Profile.CurrentUserAllHosts)
        }
    }
    Set-PSReadLineKeyHandler -Chord "Ctrl+Shift+C" -Description "Inserts ' | clip' at the end of the line/input." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(" | clip")
    }
    Set-PSReadLineKeyHandler -Chord "Ctrl+Shift+D" -Description "Adds an exit keybinding" -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Abort()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Exit")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadLineKeyHandler -Chord "Ctrl+Q" -Description "Wraps the current word in double-quotes." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::BackwardWord()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('"')
        [Microsoft.PowerShell.PSConsoleReadLine]::ForwardWord()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('"')
    }
}

# Default Parameter Values
$PSDefaultParameterValues = @{
    "Export-Csv:NoTypeInformation" = $True
    "Format-Table:AutoSize"        = { if ($Host.Name -eq "ConsoleHost") { $True } }
    "Get-EventLog:LogName"         = "System"
    "Get-EventLog:After"           = { (Get-Date).AddHours(-6) }
    "Get-Help:Full"                = $True
    "Get-Process:IncludeUsername"  = { if ($UserIsAdmin) { $True } else { $False } }
    "Get-WinEvent:FilterHashTable" = @{ LogName = "System"; StartTime = (Get-Date).AddHours(-6) }
    "Invoke-Plaster:NoLogo"        = $True
    "New-Item:ItemType"            = "File"
    "Set-Location:Path"            = $HOME
}

# Display

# Window title bar
$AdminStatus = switch ($UserIsAdmin)
{
    $True
    {
        "Elevated"
    }
    $False
    {
        "Non-Elevated"
    }
}

[string] $CurrentUser = "$([Environment]::UserDomainName)\$([Environment]::UserName)"
[string] $Titlebar = "$CurrentUser ($AdminStatus) - $(($ExecutionContext.SessionState.Path.CurrentLocation.Path) -split "::" | Select-Object -Last 1)"
$Host.UI.RawUI.WindowTitle = $Titlebar
$Host.PrivateData.VerboseForegroundColor = "Cyan"

if (Get-Module -Name "Posh-Git" -ListAvailable -ErrorAction "SilentlyContinue")
{
    [void] (Import-Module -Name "Posh-Git")
    $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $True
    $GitPromptSettings.EnableWindowTitle = $False
    $_PoshGit = $True
}

# Prompt
function prompt
{
    [string] $_PromptHost = [Environment]::MachineName
    [string] $_PromptUser = [Environment]::UserName

    $Path = $ExecutionContext.SessionState.Path.CurrentLocation
    $_CurrentLocation = switch -regex ($Path)
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
    $($_CurrentLocation | Write-Host -NoNewline -ForegroundColor "Magenta") +
    $( if ((Write-VcsStatus) -and ($_PoshGit)) { Write-VcsStatus } else { "" | Write-Host } ) +
    $("$" | Write-Host -ForegroundColor "Cyan" -NoNewline) + " "
}

if (Test-Path (Join-Path -Path $PSScriptRoot -ChildPath "extras.ps1") -ErrorAction "SilentlyContinue")
{
    # Adds items not for public consumption - work-specific etc
    . (Join-Path -Path $PSScriptRoot -ChildPath "extras.ps1")
}

# Clear-host at start-up.
if (($HasPSReadline) -and ($Host.Name -eq "ConsoleHost"))
{
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()
}
else
{
    Clear-Host
}
# Clean-up stray variables before going out into the wild.
Remove-Variable "Alias", "Admin", "AliasSplat", "CurrentUserID", "HasPSReadLine", "NewAliases", "Titlebar", "WindowsPrincipal", "UserIsAdmin", "_HistoryHandlerScriptBlock", "_ReadlineOptions" -ErrorAction "SilentlyContinue"