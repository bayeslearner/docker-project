param(
    [Parameter(Mandatory=$true, HelpMessage="Path to the directory containing the YAML config file.")]
    [string]$ConfigDirectory,

    [Parameter(HelpMessage="Name of the YAML config file. Defaults to 'docker-project.yaml'.")]
    [string]$ConfigFileName = "docker-project.yaml",

    [Parameter(Mandatory=$true, HelpMessage="Arguments to pass to 'docker-compose' command.")]
    [string]$ComposeArgs
)

function Show-Help {
    Write-Host "Usage: `n"
    Write-Host "    ./docker-project.ps1 -ConfigDirectory <directory> [-ConfigFileName <file name>] -ComposeArgs <arguments>`n`n"
    Write-Host "Parameters:`n"
    Write-Host "    -ConfigDirectory: Path to the directory containing the YAML config file. This parameter is required.`n"
    Write-Host "    -ConfigFileName: Name of the YAML config file. Defaults to 'docker-project.yaml'.`n"
    Write-Host "    -ComposeArgs: Arguments to pass to 'docker-compose' command. This parameter is required.`n"
    exit
}

if ($ConfigDirectory -eq "--help" -or $ConfigDirectory -eq "-h") {
    Show-Help
}

$configPath = Join-Path $ConfigDirectory $ConfigFileName

if (-not (Test-Path $configPath)) {
    Write-Error "Config file not found: $configPath"
    exit
}

$config = Get-Content $configPath | ConvertFrom-Yaml

foreach ($project in $config) {
    Write-Host "Project: $($project.Name)"
    foreach ($dir in $project.Directories) {
        $dirPath = Join-Path $ConfigDirectory $dir
        if (-not (Test-Path $dirPath)) {
            Write-Warning "Directory not found: $dirPath"
            continue
        }
        if ($ComposeArgs -eq "up") {
            $ComposeArgs += " -d"
        }
        if ($ComposeArgs -like "make*") {
            $command = $ComposeArgs
        } elseif ($ComposeArgs -eq "logs") {
            Write-Warning "Command 'logs' is not implemented yet."
            continue
        } else {
            $command = "docker-compose " + $ComposeArgs
        }
        Write-Host "Invoking command '$command' in directory '$dirPath'"
        Push-Location $dirPath
        Invoke-Expression $command
        Pop-Location
    }
}
