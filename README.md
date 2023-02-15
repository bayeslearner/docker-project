docker-project.ps1
docker-project.ps1 is a PowerShell script for traversing a list of directories defined in a YAML config file and invoking a Docker Compose command on each directory.

Usage
```
./docker-project.ps1 [-ConfigPath <path>] [-Command <command>] [-Help] [-Verbose]
Arguments
-ConfigPath <path>: The path to the YAML config file. Defaults to ./docker-project.yaml.
-Command <command>: The Docker Compose command to run. Defaults to up. If the command is up, it will be appended with the -d flag. If the command is logs, a message will be printed saying that it is not yet implemented. If the command starts with make, it will not be concatenated with docker-compose.
-Help: Prints the help message.
-Verbose: Prints verbose output.
```

Config File Format
The YAML config file should contain a list of projects, where each project is defined by a Name and a list of Directories. Each Directories entry is a relative path to the directory to be traversed.

Here's an example of a config file:

```
- Name: project1
  Directories:
    - services/api
    - services/db
- Name: project2
  Directories:
    - services/frontend
    - services/backend
In addition, you can reference other projects using YAML anchors. For example:

yaml
Copy code
- &project1
  Name: project1
  Directories:
    - services/api
    - services/db

- Name: project2
  Directories:
    - services/frontend
    - services/backend

- Name: project3
  Directories:
    - services/backend
    - services/cache
    - ../project2/services/frontend

- Name: project4
  Directories:
    - services/frontend
    - services/backend
    - *project1
```
In this example, project4 references project1 using the * syntax.

License
This code is released under the MIT License. See LICENSE for more information.
