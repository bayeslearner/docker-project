[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$configdirectory = $pwd,

    [Parameter(Mandatory=$false)]
    [string]$configname = "docker-project.yaml",

    [Parameter(Mandatory=$false)]
    [string]$project = "default",

    [Parameter(Mandatory=$true, Position=1)]
    [string]$command
)

function Invoke-CommandInDirectory {
    param(
        [Parameter(Mandatory=$true)]
        [string]$directory,
        
        [Parameter(Mandatory=$true)]
        [string]$command
    )

    Write-Host "Running command '$command' in directory '$directory'"
    Set-Location -Path $directory
    Invoke-Expression $command
    Set-Location -Path $script:initialDirectory
}

try {
    $initialDirectory = $pwd
    $configPath = Join-Path -Path $configdirectory -ChildPath $configname

    if (-not(Test-Path $configPath)) {
        throw "Config file '$configPath' not found"
    }

    $config = Get-Content -Path $configPath | ConvertFrom-Yaml
    $projects = $config.psobject.Properties | Where-Object { $_.Type.Name -eq "Array" } | Select-Object -ExpandProperty Name

    if ($project -ne "all" -and -not($projects.Contains($project))) {
        throw "Project '$project' not found in config file"
    }

    if ($project -eq "all") {
        $projectsToProcess = $projects
    } else {
        $projectsToProcess = $project
    }

    foreach ($projectToProcess in $projectsToProcess) {
        $directories = $config.$projectToProcess
        $commandToExecute = "docker-compose $($command)"

        if ($command -eq "up") {
            $commandToExecute += " -d"
        }

        foreach ($directory in $directories) {
            if ($command -eq "logs") {
                Write-Host "The logs command is not implemented yet"
            } elseif ($command -like "make*") {
                Invoke-CommandInDirectory -directory $directory -command $command
            } else {
                Invoke-CommandInDirectory -directory $directory -command $commandToExecute
            }
        }
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
finally {
    Set-Location -Path $initialDirectory
}
