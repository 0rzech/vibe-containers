# Vibe Containers

This project provides a containerized environment for running [Mistral Vibe](https://mistral.ai/products/vibe) open source coding agent CLI.
It includes a `Containerfile` and helper scripts to build and run containers with proper user permissions and a bit better security settings.

## Features

- **A Bit More Secure Container**: Runs with dropped capabilities and no new privileges.
- **User Namespace Isolation**: Uses `--userns keep-id` for proper file permissions.
- **Persistent Configuration**: Mounts the vibe configuration directory.
- **Current Directory Access**: Mounts the current working directory.

## Files

- `Containerfile`: Dockerfile that builds a Fedora-based image with Mistral Vibe installed and a few CLI binaries.
- `build`: Script to build the container image with proper user/group arguments.
- `bin/vibe-container`: Script to run the Mistral Vibe container.
- `bin/vibe-acp-container`: Script to run the Mistral Vibe ACP ([Agent Client Protocol](https://agentclientprotocol.com)) container.

## Prerequisites

- [Podman](https://podman.io) installed.
- Proper user permissions to run containers.
- At least [Bash](https://www.gnu.org/software/bash/) version 4.
  [MacOS](https://www.apple.com/pl/os/macos/) comes with Bash 3, but users can install an up-to-date version themselves.

## Usage

### Build the Container

```bash
./build
```

This will create a container image tagged as `vibe-sandbox` with your current user's UID/GID.

### Run Mistral Vibe

```bash
./bin/vibe-container
```

This launches an interactive container with Mistral Vibe running in your current directory.

You can also specify a custom entrypoint, for example:

```bash
ENTRYPOINT=bash ./bin/vibe-container -c 'ls -ahlZ'
```

### Run Mistral Vibe ACP

```bash
./bin/vibe-acp-container
```

This launches an interactive container with Mistral Vibe ACP running in your current directory.

This script is for use with editors and IDEs with support ACP.

You can also specify a custom entrypoint, for example:

```bash
ENTRYPOINT=bash ./bin/vibe-acp-container -c 'ls -ahlZ'
```

### Working Directory Validation

The scripts validate the working directory against absolute path prefixes defined in `${XDG_CONFIG_HOME}/vibe-containers/work-dir-prefix.list` on [Linux](https://www.kernel.org) distributions and `~/.config/vibe-containers/work-dir-prefix.list` on other systems.

If the file exists, the working directory must start with one of the prefixes listed in the file, one per line.
If the file is empty, the working directory will not match any prefix, and thus the scripts will refuse to start the container.

Example:

```bash
mkdir -p '~/.config/vibe-containers'
echo '/home/user/projects' > '~/.config/vibe-containers/work-dir-prefix.list'
```

This ensures containers only run in approved directories.

It is recommended to maintain the prefix list because the scripts will recursively change the working directory's [SELinux](https://github.com/SELinuxProject/selinux) context to grant access to Podman containers.

## How it Works

The working directory inside containers will be the same as the host's working directory (`.`) from which the containers are run.
The containers assume rootless Podman with a non-root user inside.
This is why host UID and GID are the same inside containers.

## Limitations

- The agent can only run binaries that are already in the container, which in this case means no SDKs.
- Containers have network access.
- The scripts assume that the `save_dir` in `config.toml` is set to effective value of `${VIBE_HOME:-${HOME}/.vibe}`.

## Security Features

- All capabilities dropped (`--cap-drop all`).
- No new privileges (`--security-opt no-new-privileges`).
- User namespace isolation (`--userns keep-id`).
- Root password disabled and account expired.

## Environment Variables

- `VIBE_HOME`: Path to the vibe configuration directory (defaults to `~/.vibe`).
- `ENTRYPOINT`: Entrypoint executable.
  Defaults to `vibe` for `vibe-container` and `vibe-acp` for `vibe-acp-container`.

## License

    Vibe Containers
    Copyright (C) 2026  Piotr Orzechowski

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Disclaimer

This project is in no way associated with or endorsed by [Mistral AI](https://mistral.ai).
