# docker-project.ps1
docker-project.ps1 is a PowerShell script for traversing a list of directories defined in a YAML config file and invoking a Docker Compose command on each directory.

Usage
```
NAME
    docker-project.ps1 - Script to run docker-compose commands on specified directories.

SYNOPSIS
    docker-project.ps1 [-Project <String>] [-ConfigDirectory <String>] [-ConfigFile <String>] -Command <String> [<CommonParameters>]

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

REMARKS
    To use this script, you must have Docker and Docker Compose installed.

    If the specified directory for a project does not exist, the script will skip that project and continue to the next one.

AUTHOR
    ChatGPT

```

Config File Format
The YAML config file should contain a list of projects, where each project is defined by a Name and a list of Directories. Each Directories entry is a relative path to the directory to be traversed.

Here's an example of a config file:
```
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
```
In this example, project4 references project1 using the * syntax.

License
This code is released under the MIT License. See LICENSE for more information.
