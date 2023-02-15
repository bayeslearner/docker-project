[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$configdirectory = $pwd,

    [Parameter(Mandatory=$false)]
    [string]$configname = "docker-project.yaml",

    [Parameter(Mandatory=$false)]
    [string]$project = "default"
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

    if (-not($projects.Contains($project))) {
        throw "Project '$project' not found in config file"
    }

    $directories = $config.$project
    $command = "docker-compose $($args -join ' ')"

    if ($args[0] -eq "up") {
        $command += " -d"
    }

    foreach ($directory in $directories) {
        if ($args[0] -eq "logs") {
            Write-Host "The logs command is not implemented yet"
        } elseif ($args[0] -like "make*") {
            Invoke-CommandInDirectory -directory $directory -command $args
        } else {
            Invoke-CommandInDirectory -directory $directory -command $command
        }
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
finally {
    Set-Location -Path $initialDirectory
}
