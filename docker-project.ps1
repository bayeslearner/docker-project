[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$configdirectory = $pwd,
    
    [Parameter(Mandatory=$false)]
    [string]$configname = "docker-project.yaml",

    [Parameter(Mandatory=$true, Position=1)]
    [string]$projectname,

    [Parameter(Mandatory=$true, Position=2)]
    [string]$command,

    [Parameter(Mandatory=$false)]
    [string]$args = ""
)

# Define the full path to the config file
$configfile = Join-Path -Path $configdirectory -ChildPath $configname

# Check if the config file exists
if (-not(Test-Path $configfile -PathType Leaf)) {
    Write-Error "Config file not found: $configfile"
    exit 1
}

# Load the config file
$config = Get-Content $configfile | ConvertFrom-Yaml

# Check if the specified project exists in the config file
if (-not($config.ContainsKey($projectname))) {
    Write-Error "Project not found: $projectname"
    exit 1
}

# Get the directories for the specified project
$projectdirs = $config.$projectname

# Invoke the command on each directory
foreach ($dir in $projectdirs) {
    # Change to the directory
    Set-Location $dir

    # Build the command to invoke
    if ($command -like "make*") {
        $fullcommand = "$command $args"
    }
    elseif ($command -eq "up") {
        $fullcommand = "docker-compose up -d $args"
    }
    elseif ($command -eq "logs") {
        Write-Host "Command 'logs' is not implemented yet."
        exit 1
    }
    else {
        $fullcommand = "docker-compose $command $args"
    }

    # Invoke the command
    Write-Host "Invoking command '$fullcommand' in directory '$dir'"
    Invoke-Expression $fullcommand
}
