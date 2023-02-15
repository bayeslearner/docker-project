<#
.SYNOPSIS
Runs Docker Compose commands on multiple projects defined in a YAML configuration file.

.DESCRIPTION
This script reads a YAML configuration file that defines a list of projects and their directories to run Docker Compose commands on. For each project, the script changes to the project directory, then runs a Docker Compose command specified by the user.

.PARAMETER Command
The Docker Compose command to run on each project. Defaults to "up".

.PARAMETER ConfigPath
The path to the YAML configuration file. Defaults to "docker-project.yaml" in the current directory.

.PARAMETER ConfigDirectory
The directory where the YAML configuration file is located. Defaults to the current directory.

.PARAMETER FileName
The name of the YAML configuration file. If specified, overrides the default file name "docker-project.yaml".

.PARAMETER Help
Displays the script help information.

.PARAMETER Verbose
Enables verbose output.

.EXAMPLE
.\docker-project.ps1 -Command down -ConfigPath config/docker-project.yaml -Verbose
Runs "docker-compose down" on each project defined in the "config/docker-project.yaml" file, and displays verbose output.

.NOTES
This script requires the following PowerShell modules to be installed: "powershell-yaml", "InvokeBuild". You can install them using the following commands:
    Install-Module powershell-yaml
    Install-Module InvokeBuild
#>

# Import required modules
Import-Module powershell-yaml
Import-Module InvokeBuild

# Define script arguments
param (
    [string]$Command = "up",
    [string]$ConfigPath = "docker-project.yaml",
    [string]$ConfigDirectory = $PWD,
    [string]$FileName,
    [switch]$Help,
    [switch]$Verbose
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Definition
    return
}

if ($FileName) {
    $ConfigPath = Join-Path $ConfigDirectory $FileName
}

# Read configuration file
$Projects = Get-YamlContent $ConfigPath

if ($Verbose) {
    Write-Host "Using config file: $ConfigPath"
}

foreach ($ProjectName in $Projects.Keys) {
    $Project = $Projects[$ProjectName]

    if ($Verbose) {
        Write-Host "Project: $ProjectName"
    }

    # Traverse project directories and run command
    foreach ($Directory in $Project) {
        if ($Verbose) {
            Write-Host "Directory: $Directory"
        }

        if (Test-Path $Directory) {
            Push-Location $Directory

            $CommandToRun = ""
            if ($Command.StartsWith("make")) {
                $CommandToRun = $Command
            }
            else {
                $CommandToRun = "docker-compose $Command"
                if ($Command -eq "up") {
                    $CommandToRun += " -d"
                }
                elseif ($Command -eq "logs") {
                    Write-Warning "The 'logs' command is not implemented yet."
                    Pop-Location
                    continue
                }
            }

            if ($Verbose) {
                Write-Host "Running command: $CommandToRun"
            }

            Invoke-Command -ScriptBlock { Invoke-Build -Task $CommandToRun } -Verbose:$Verbose

            Pop-Location
        }
        else {
            Write-Warning "Directory not found: $Directory"
        }
    }
}
