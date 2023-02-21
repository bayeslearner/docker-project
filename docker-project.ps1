<#
.NAME
    docker-project.ps1 - Script to run docker-compose commands on specified directories.

.SYNOPSIS
    docker-project.ps1 [-Project <String>] [-ConfigDirectory <String>] [-ConfigFile <String>] [-Command <String>] [<CommonParameters>]

.DESCRIPTION
    This script reads a YAML configuration file and runs specified docker-compose commands on the directories listed in the file.

    Required Parameters:
        -Command <String>
            The docker-compose command to run. 



    Optional Parameters:
        -ConfigDirectory <String>
            The path to the directory where the configuration file is located. Default is the current directory.
        -ConfigFile <String>
            The name of the configuration file. Default is 'docker-project.yaml'.
        -Project <String>
            The name of the project as specified in the configuration file.

.EXAMPLES
    docker-project.ps1 -Project default -Command up 
    docker-project.ps1 -Project default -Command up 
    docker-project.ps1 -Project project1  -f ./compose-budibase/docker-compose.yaml config
    docker-project.ps1 -Project project1 -ConfigDirectory c:\config\ -ConfigFile my-config.yml -f ./compose-budibase/docker-compose.yaml config

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$Project = "default",

    [Parameter(Position=0, ValueFromRemainingArguments= $true)]
    [string]$Command="up",

    [Parameter(Mandatory=$false)]
    [string]$ConfigDirectory = ".",

    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "docker-project.yml",

    [Parameter(ParameterSetName="Help")]
    [switch]$Help
)


function Show-Help {
    $helpText = @"
.NAME
    docker-project.ps1 - Script to run docker-compose commands on specified directories.

.SYNOPSIS
    docker-project.ps1 [-Project <String>] [-ConfigDirectory <String>] [-ConfigFile <String>] [-Command <String>] [<CommonParameters>]

.DESCRIPTION
    This script reads a YAML configuration file and runs specified docker-compose commands on the directories listed in the file.

    Required Parameters:
        -Command <String>
            The docker-compose command to run. 



    Optional Parameters:
        -ConfigDirectory <String>
            The path to the directory where the configuration file is located. Default is the current directory.
        -ConfigFile <String>
            The name of the configuration file. Default is 'docker-project.yaml'.
        -Project <String>
            The name of the project as specified in the configuration file.

.EXAMPLES
    docker-project.ps1 -Project default -Command up 
    docker-project.ps1 -Project default -Command up 
    docker-project.ps1 -Project project1  -f ./compose-budibase/docker-compose.yaml config
    docker-project.ps1 -Project project1 -ConfigDirectory c:\config\ -ConfigFile my-config.yaml -f ./compose-budibase/docker-compose.yaml config

.CONFIG
default: &default
  - /path/to/project1
  - /path/to/project2
  - /path/to/project3

project1: &project1
  - /path/to/project4
  - /path/to/project5

project2: &project2
  - /path/to/project6

project3:
  - /path/to/project7
  - *project1
  - *project2
"@
    Write-Host $helpText
}

function Run-Command {
    param(
        [string]$command,
        [string]$directory
    )

    if ($command -eq "up") {
        $command = "docker-compose up -d"
    } elseif ($command -eq "logs") {
        Write-Host "Command logs not implemented yet"
        return
    } elseif ($command.StartsWith("make")) {
        $command = $command
    } else {
        $command = "docker-compose $command"
    }
    Push-Location
    Set-Location $directory
    Write-Host "Running command '$command' on directory '$directory'"
    Pop-Location
    #Invoke-Expression $command
}

function Get-AbsolutePath {
    param(
        [string]$Path,
        [string]$BaseDirectory
    )

    if (Test-Path $Path) {
        return @((Convert-Path $Path), $true)
    } else {
        $absolutePath = Join-Path $BaseDirectory $Path
        if (Test-Path $absolutePath) {
            return @((Convert-Path $absolutePath), $true)
        } else {
            return @($null, $false)
        }
    }
}

function RecursiveUnroll {
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipeline)]
        [object[]] $Unroll
    )

    
    process {
        foreach($item in $Unroll) {
            if($item -is [object[]] -or $item -is [System.Collections.Generic.List`1[System.Object]]) {
                RecursiveUnroll -Unroll $item
                continue
            }
            #write-host $item.GetType()
            $item
        }
    }
}

function Invoke-Project {
    param(
        [string]$projectName,
        [string]$command,
        [string]$configDirectory,
        [string]$configFile
    )

    Write-Host "Invoking project '$projectName' with command '$command'"

    $config = Get-YamlConfig -ConfigDirectory $configDirectory -ConfigFile $configFile

    $project = $config[$projectName]

    if (-not $project) {
        Write-Host "Project '$projectName' not found in configuration file"
        return
    }

    $projectUnrolled = ((RecursiveUnroll -Unroll $project)) | Select-Object -Unique

    Write-Host "total projects:$($projectUnrolled.count)"  $projectUnrolled -Separator "`n"

    foreach ($directory in $projectUnrolled) {
        $absDir,$found= Get-AbsolutePath -Path $directory -BaseDirectory $configDirectory

        if ($found) {
            Run-Command -command $command -directory $absDir
        } else {
            Write-Host "Directory '$directory' not found"
        }
    }
}

function Get-YamlConfig {
    param(
        [string]$configDirectory = ".",
        [string]$configFile = "docker-project.yml"
    )

    $configPath = Join-Path $configDirectory $configFile

    if (-not (Test-Path $configPath)) {
        Write-Host "Configuration file '$configPath' not found"
        exit
    }

    $config = Get-Content $configPath | Out-String | ConvertFrom-Yaml -Ordered -UseMergingParser
    return $config
}

if ($PSCmdlet.ParameterSetName -eq 'Help') {
    Show-Help
    exit
}

Invoke-Project -projectName $Project -command $Command -configDirectory $ConfigDirectory -configFile $configFile
