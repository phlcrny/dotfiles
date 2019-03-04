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
    # Set zsh-style tab-complete:
    $HasPSReadline = $True
    Set-PSReadlineOption -BellStyle "None"
    Set-PSReadlineKeyHandler -Key "Tab" -Function "MenuComplete"
    Set-PSReadLineKeyHandler -Key "UpArrow" -Function "HistorySearchBackward"
    Set-PSReadLineKeyHandler -Key "DownArrow" -Function "HistorySearchForward"
    Set-PSReadlineKeyHandler -Chord "Ctrl+K" -Function "DeleteToEnd"
    Set-PSReadlineKeyHandler -Chord "Ctrl+H" -Description "Uses the default action on the built-in `$HOME variable. It should open in Explorer." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("ii $HOME")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+P" -Description "Reloads your Powershell profile." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(". $($Profile.CurrentUserAllHosts)")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+Shift+P" -Description "Opens the folder where your profile is saved." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Invoke-Item $(Split-Path -Path $Profile.CurrentUserAllHosts)")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+F" -Description "Inserts Get-ChildItem with a standard search keybinding." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Get-ChildItem ")
    }
    Set-PSReadlineKeyHandler -Chord "Ctrl+W,Ctrl+D" -Description "Copies your current working directory to the clipboard." -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Get-Item -Path '.' | Select-Object -ExpandProperty 'FullName' | clip")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

# Default Parameter Values
$PSDefaultParameterValues = @{
    "Export-Csv:NoTypeInformation" = $True
    "Format-Table:AutoSize"        = $(if ($Host.Name -eq "ConsoleHost")
        {
            $True
        })
    "Get-EventLog:LogName"         = "System"
    "Get-EventLog:After"           = {(Get-Date).AddHours(-6)}
    "Get-Help:Full"                = $True
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
            " " + $(Write-Host "") + $("$" | Write-Host -ForegroundColor "Cyan" -NoNewline)
        }
        else
        {
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
Remove-Variable "CurrentUserID", "WindowsPrincipal", "Admin", "UserIsAdmin", "Titlebar", "AliasSplat", "HasPSReadLine" -ErrorAction "SilentlyContinue"