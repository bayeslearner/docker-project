function Show-Help {
    $helpText = @"
NAME
    docker-project.ps1 - Script to run docker-compose commands on specified directories.

SYNOPSIS
    docker-project.ps1 [-Project <String>] [-ConfigDirectory <String>] [-ConfigFile <String>] [-Command <String>] [<CommonParameters>]

DESCRIPTION
    This script reads a YAML configuration file and runs specified docker-compose commands on the directories listed in the file.

    Required Parameters:
        -Command <String>
            The docker-compose command to run. Options are: up, down, logs.
        -Project <String>
            The name of the project as specified in the configuration file.

    Optional Parameters:
        -ConfigDirectory <String>
            The path to the directory where the configuration file is located. Default is the current directory.
        -ConfigFile <String>
            The name of the configuration file. Default is 'docker-project.yaml'.

EXAMPLES
    docker-project.ps1 -Command up -Project default
    docker-project.ps1 -Command logs -Project project1 -ConfigDirectory c:\config\ -ConfigFile my-config.yaml

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
        $command = $command.Substring(4)
    } else {
        $command = "docker-compose $command"
    }

    Set-Location $directory
    Write-Host "Running command '$command' on directory '$directory'"
    Invoke-Expression $command
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

    foreach ($directory in $project) {
        if (Test-Path $directory) {
            Run-Command -command $command -directory $directory
        } else {
            Write-Host "Directory '$directory' not found"
        }
    }
}

function Get-YamlConfig {
    param(
        [string]$configDirectory = ".",
        [string]$configFile = "docker-project.yaml"
    )

    $configPath = Join-Path $configDirectory $configFile

    if (-not (Test-Path $configPath)) {
        Write-Host "Configuration file '$configPath' not found"
        exit
    }

    $config = Get-Content $configPath | Out-String | ConvertFrom-Yaml
    return $config
}

param (
    [Parameter(Mandatory=$false)]
    [string]$Project = "default",

    [Parameter(Mandatory=$true)]
    [string]$Command,

    [Parameter(Mandatory=$false)]
    [string]$ConfigDirectory = ".",

    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "docker-project.yaml"
)

Invoke-Project -projectName $Project -command $Command -configDirectory $ConfigDirectory -configFile $ConfigFile
