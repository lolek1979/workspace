# WSL Bash Utilities

This folder provides Bash equivalents of the original PowerShell helper modules so the same setup and maintenance tasks can be run inside Ubuntu or other Linux distributions (including WSL).

## Prerequisites

- `bash`, `python3`, and the relevant tooling (`git`, `dotnet`, `node`, `pwsh`) available on `PATH`
- `resources/scripts/repositories.json` populated with the repositories you want to sync

## Scripts

- `git.sh`
  - `test-version <required>` &mdash; verifies `git --version` includes the required substring.
  - `restore [-f file] [-b base] [-d branch] [-l log]` &mdash; clones or updates every repository listed in `repositories.json`. By default it uses the current directory as the base and `resources/scripts/repositories.json` for the repository list. Use `-l` to capture git output in a log file.
- `dotnet.sh`
  - `test-version [-v version] [-g global.json]` &mdash; checks whether the required .NET SDK is installed. Without `-v` it reads `Sdk.Version` from `global.json` (default `./global.json`).
- `node.sh`
  - `test-version <required>` &mdash; ensures `node --version` matches the specified major/minor/patch (e.g. `18.17.1`).
- `pwsh.sh`
  - `test-version <required>` &mdash; confirms that PowerShell (`pwsh`) is installed and the version starts with the required string.

Each script supports `-h`/`--help` to display usage information. Run them from your repository root, for example:

```bash
./resources/scripts/wsl/git.sh restore -b ~/workspace -l ~/logs/git-restore.log
./resources/scripts/wsl/dotnet.sh test-version
./resources/scripts/wsl/node.sh test-version 18.17
./resources/scripts/wsl/pwsh.sh test-version 7.4.0
```
