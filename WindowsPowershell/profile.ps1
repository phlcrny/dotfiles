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
    $HasPSReadline = $True
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
$SmallScreenPrompt = $False

# Prompt
function prompt
{
    [string] $Titlebar = "$CurrentUser ($AdminStatus) - $(($ExecutionContext.SessionState.Path.CurrentLocation.Path) -split "::" | Select-Object -Last 1)"
    [string] $PromptHost = [Environment]::MachineName
    [string] $PromptUser = [Environment]::UserName
    $Host.UI.RawUI.WindowTitle = $Titlebar

    function Format-CurrentPath ($Path)
    {
        switch -regex ($Path)
        {
            "^C:\\Users\\$PromptUser"
            {
                $Path -replace "^C:\\Users\\$PromptUser", "~"
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

    $CurrentLocation = Format-CurrentPath -Path $ExecutionContext.SessionState.Path.CurrentLocation
    $SimulatedPrompt = "$PromptUser on $PromptHost at $CurrentLocation"
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
    $($PromptUser | Write-Host -NoNewline -ForegroundColor "Cyan") +
    $(" on " | Write-Host -NoNewline) +
    $($PromptHost | Write-Host -NoNewline -ForegroundColor "Green") +
    $(" in " | Write-Host -NoNewline) +
    $($CurrentLocation | Write-Host -ForegroundColor "Magenta" -NoNewline) +
    $(
        if (($SimulatedPrompt.Length -ge 80) -or ($SmallScreenPrompt)) # I don't want to have my commands wrap on to another line just because of a long path.
        {
            if ($HasPSReadline)
            {
                Set-PSReadLineOption -ExtraPromptLineCount 1
            }
            " " + $(Write-Host "") + $("$" | Write-Host -ForegroundColor "Cyan" -NoNewline)
        }
        else
        {
            if ($HasPSReadline)
            {
                Set-PSReadLineOption -ExtraPromptLineCount 0
            }
            $(" $" | Write-Host -ForegroundColor "Cyan" -NoNewline)
        }
    ) + " "
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
Remove-Variable "Alias", "Admin", "AliasSplat", "CurrentUserID", "HasPSReadLine", "NewAliases", "Titlebar", "WindowsPrincipal", "UserIsAdmin" -ErrorAction "SilentlyContinue"