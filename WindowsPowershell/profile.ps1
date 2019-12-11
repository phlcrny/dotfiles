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
        Name        = "~"
        Value       = $HOME
        Description = "Take me Home."
    }

    @{
        Name        = "devicemanager"
        Value       = "hdwwiz.cpl"
        Description = "Alias for the Device Manager Control Panel applet."
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
        Name        = "grep"
        Value       = "Select-String"
        Description = "Aliases grep to Select-String cmdlet."
    }

    @{
        Name        = "Hosts"
        Value       = $Hosts
        Description = "Short-hand for the Hosts file."
    }

    @{
        Name        = "Import"
        Value       = "Import-Module"
        Description = "Short-hand for Import-Module"
    }

    @{
        Name        = "Touch"
        Value       = "New-Item"
        Description = "Cross-platform laziness"
    }

    $(
        if (Test-Path "C:\Program Files\Git\usr\bin\vim.exe")
        {
            @{
                Name        = "vim"
                Value       = "C:\Program Files\Git\usr\bin\vim.exe"
                Description = "Alias for the vim executable."
            }
        }
    )
)

forEach ($Alias in $NewAliases)
{
    if (-not (Test-Path -Path "alias:\$($Alias.Name)" -ErrorAction "SilentlyContinue"))
    {
        $AliasSplat = @{
            Name        = $Alias.Name
            Value       = $Alias.Value
            Description = $Alias.Description
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
    Set-PSReadlineOption @_ReadlineOptions
    Set-PSReadlineKeyHandler -Key "Tab" -Function "MenuComplete"
    # Set zsh-style tab-complete
    Set-PSReadlineKeyHandler -Key "UpArrow" -Function "HistorySearchBackward"
    Set-PSReadlineKeyHandler -Key "DownArrow" -Function "HistorySearchForward"
    # Amend default search behaviour
    Set-PSReadlineKeyHandler -Chord "Ctrl+K" -Function "DeleteToEnd"
    # Delete the whole or remainder of the line.

    # Custom bindings
    Set-PSReadlineKeyHandler -Chord "Ctrl+H" -Description "Uses the default action on the built-in `$HOME variable. It should open in Explorer." -ScriptBlock {
        Invoke-Item -Path $HOME
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+P" -Description "Reloads your Powershell profile." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(". $($Profile.CurrentUserAllHosts)")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+P" -Description "Opens the folder where your profile is saved." -ScriptBlock {
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
    Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+C" -Description "Inserts ' | clip' at the end of the line/input." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(" | clip")
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+D" -Description "Adds an exit keybinding" -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Abort()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Exit")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+E" -Description "Attempts to open the current folder in Visual Studio Code." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("code .")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+F" -Description "Inserts Get-ChildItem with a standard search keybinding." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Get-ChildItem ")
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+W,Ctrl+D" -Description "Copies your current working directory to the clipboard." -ScriptBlock {
        Get-Item -Path '.' | Select-Object -ExpandProperty 'FullName' | clip.exe
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+Q" -Description "Wraps the current word in double-quotes." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::BackwardWord()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('"')
        [Microsoft.PowerShell.PSConsoleReadLine]::ForwardWord()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('"')
    }
}

# Default Parameter Values
$PSDefaultParameterValues = @{
    "cd:Path"                      = $HOME
    "Export-Csv:NoTypeInformation" = $True
    "Format-Table:AutoSize"        = { if ($Host.Name -eq "ConsoleHost") { $True } }
    "Get-EventLog:LogName"         = "System"
    "Get-EventLog:After"           = { (Get-Date).AddHours(-6) }
    "Get-Help:Full"                = $True
    "Get-Process:IncludeUsername"  = { if ($UserIsAdmin) { $True } else { $False } }
    "ps:IncludeUsername"           = { if ($UserIsAdmin) { $True } else { $False } }
    "New-Item:ItemType"            = "File"
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
                Set-PSReadlineOption -ExtraPromptLineCount 1
            }
            " " + $(Write-Host "") + $("$" | Write-Host -ForegroundColor "Cyan" -NoNewline)
        }
        else
        {
            if ($HasPSReadline)
            {
                Set-PSReadlineOption -ExtraPromptLineCount 0
            }
            $(" $" | Write-Host -ForegroundColor "Cyan" -NoNewline)
        }
    ) + " "
}

if (Test-Path "$PSScriptRoot\work_extras.ps1" -ErrorAction "SilentlyContinue")
{
    # Adds work-specific items, not for public consumption.
    . (Join-Path -Path $PSScriptRoot -ChildPath "work_extras.ps1")
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