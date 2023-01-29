# Force Powershell to use TLS 1.2 for HTTPS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Lazy variable

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
        Name  = "Touch"
        Value = "New-Item"
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
try
{
    $_HistoryHandlerScriptBlock = {
        param(
            [string] $Line
        )

        $SkipExclusion = '(\$env\:(\w|\d)+(key|token|password)( +)?=)|((\-\w+\S)?(assecurestring|asplaintext)( +)?(=)?)'
        $Exclusions = @(
            'powershell_ise'
            'cls'
            'cd'
            'cd ..'
            'ls'
            'ls -l'
            'ls -al'
            'Get-Help'
            'help'
            'ii'
            'ii .'
            'skip_pshistory'
        )

        if (($Line.ToLower() -notmatch $SkipExclusion) -and ($Line.ToLower() -notin $Exclusions))
        {
            if ($Line.Length -ge 5)
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
        ExtraPromptLineCount          = 1
        HistoryNoDuplicates           = $True
        HistorySearchCursorMovesToEnd = $True
        ShowTooltips                  = $False
    }

    Set-PSReadLineOption @_ReadlineOptions
    Set-PSReadLineKeyHandler -Key 'Tab' -Function 'MenuComplete'
    Set-PSReadLineKeyHandler -Key 'UpArrow' -Function 'HistorySearchBackward'
    Set-PSReadLineKeyHandler -Key 'DownArrow' -Function "HistorySearchForward"
}
catch [System.Management.Automation.CommandNotFoundException]
{
    Write-Warning "Unable to set PSReadline settings"
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
if (Get-Module -Name "Posh-Git" -ListAvailable -ErrorAction "SilentlyContinue")
{
    [void] (Import-Module -Name "Posh-Git")
}

# Via Mathias Jessen:
# https://stackoverflow.com/a/68314618/11838387
$ExecutionContext.InvokeCommand.CommandNotFoundAction = {
    param(
        [string] $CommandName,
        [System.Management.Automation.CommandLookupEventArgs] $EventArgs
    )

    # Test if the "command" in question is actually a directory path
    if (Test-Path $CommandName -PathType 'Container')
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
    # This is lazy
    # Rather than checking for the required fonts, I'm trusting I'll only install starship where
    # I can/will also install the fonts
    Import-Module -Name 'Terminal-Icons' -ErrorAction 'SilentlyContinue'
}

if (Test-Path ([System.IO.Path]::Combine($PSScriptRoot, 'extras.ps1')) -ErrorAction "SilentlyContinue")
{
    # Adds items not for public consumption - work-specific etc
    . ([System.IO.Path]::Combine($PSScriptRoot, 'extras.ps1'))
}

# Clean-up stray variables before going out into the wild.
$Alias, $Admin, $AliasSplat, $CurrentUserID, $HasPSReadLine, $NewAliases, $Titlebar, $WindowsPrincipal, $UserIsAdmin, $_HistoryHandlerScriptBlock, $_ReadlineOptions = $Null
