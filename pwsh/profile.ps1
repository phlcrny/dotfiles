if (Get-Module -Name 'Posh-Git' -ListAvailable -ErrorAction 'SilentlyContinue')
{
    [void] (Import-Module -Name 'Posh-Git')
}

# Aliases and preferences

# Aliases
$_NewAliases = @(

    if ($Null -ne (Get-Command 'bat' -ErrorAction 'SilentlyContinue'))
    {
        @{
            Name  = 'cat'
            Value = (Get-Command 'bat')[0].Source
        }
    }

    if ($Null -ne (Get-Command 'hdwwiz.cpl' -ErrorAction 'SilentlyContinue'))
    {
        @{
            Name  = 'devicemanager'
            Value = 'hdwwiz.cpl'
        }
    }

    if (Get-Module -Name 'z' -ListAvailable -ErrorAction 'SilentlyContinue')
    {
        @{
            Name  = 'j'
            Value = 'z'
        }
    }

    @{
        Name  = 'll'
        Value = 'Get-ChildItem'
    }

    @{
        Name  = 'gd'
        Value = 'Get-Date'
    }

    @{
        Name  = 'gfh'
        Value = 'Get-Help'
    }

    $(
        if (Test-Path 'C:\Program Files\Git\usr\bin\vim.exe')
        {
            @{
                Name  = 'vim'
                Value = 'C:\Program Files\Git\usr\bin\vim.exe'
            }
        }
    )
)

foreach ($_Alias in $_NewAliases)
{
    if (-not ((Test-Path -Path "alias:\$($_Alias.Name)" -ErrorAction 'SilentlyContinue') -and
            (Get-Command -Name $_Alias.Name -ErrorAction 'SilentlyContinue')))
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
        [string] $InputLine
    )

    $Line = $InputLine.ToLower()
    $ExclusionsList = @(
        'get-help'
        'ls -al'
        'powershell_ise'
        'skip_pshistory'
    )

    if ($Line.Length -lt 6)
    {
        $False
    }
    elseif ($Line -in $ExclusionsList)
    {
        $False
    }
    elseif ($Line -match '^\$env:([a-z]+)?(token|key|pass)')
    {
        $False
    }
    elseif ($Line -match '-(asplaintext|assecurestring)')
    {
        $False
    }
    elseif ($Line -match '^ ')
    {
        $False
    }
    else
    {
        $InputLine
    }
}

$_ReadlineOptions = @{
    AddToHistoryHandler           = $_HistoryHandlerScriptBlock
    BellStyle                     = 'None'
    HistoryNoDuplicates           = $True
    HistorySearchCursorMovesToEnd = $True
    ShowTooltips                  = $False
}

Set-PSReadLineOption @_ReadlineOptions
Set-PSReadLineOption -PredictionSource 'History' -ErrorAction 'SilentlyContinue' # In case we're using an old version of PSReadline
Set-PSReadLineKeyHandler -Key 'Tab' -Function 'MenuComplete'
Set-PSReadLineKeyHandler -Key 'UpArrow' -Function 'HistorySearchBackward'
Set-PSReadLineKeyHandler -Key 'DownArrow' -Function 'HistorySearchForward'
$ENV:POWERSHELL_UPDATECHECK = 'LTS'
# Why would you choose bright green as defaults?
$PSStyle.Formatting.TableHeader = $PSStyle.Foreground.BrightBlack
$PSStyle.Formatting.FormatAccent = $PSStyle.Foreground.White

# Default Parameter Values
$PSDefaultParameterValues = @{
    'Format-Table:AutoSize' = $True
    'Get-Help:Full'         = $True
    'Invoke-Plaster:NoLogo' = $True
    'New-Item:ItemType'     = 'File'
    'Set-Location:Path'     = $HOME
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

if (Get-Command 'starship' -ErrorAction 'SilentlyContinue')
{
    Invoke-Expression (&starship init powershell)
    # This is lazy
    # Rather than checking for the required fonts, I'm trusting I'll only install starship where
    # I can/will also install the fonts
    Import-Module -Name 'Terminal-Icons' -ErrorAction 'SilentlyContinue'
}

$ENV:PIP_REQUIRE_VIRTUALENV = 'true'
$ENV:RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc"

if (Test-Path ([System.IO.Path]::Combine($PSScriptRoot, 'extras.ps1')) -ErrorAction 'SilentlyContinue')
{
    # Adds items not for public consumption - work-specific etc
    . ([System.IO.Path]::Combine($PSScriptRoot, 'extras.ps1'))
}

# Variable clean-up.
$Alias, $AliasSplat, $CurrentUser, $NewAliases = $Null
